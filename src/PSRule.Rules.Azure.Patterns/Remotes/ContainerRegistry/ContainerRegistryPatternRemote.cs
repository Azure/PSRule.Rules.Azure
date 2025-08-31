// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Immutable;
using System.Text.Json;
using Azure.Containers.ContainerRegistry;
using Azure.Core;
using Microsoft.Extensions.Logging;

namespace PSRule.Rules.Azure.Patterns.Remotes.ContainerRegistry;

internal sealed class ContainerRegistryPatternRemote(ILogger logger, Uri uri, TokenCredential tokenCredential) : IPatternRegistryRemote
{
    private const string PatternMediaType = "application/vnd.ms.ps-rule-azure.pattern.v1+json";
    private const string PatternLayerMediaType = "application/vnd.ms.ps-rule-azure.pattern.layer.v1+json";

    private readonly static JsonSerializerOptions _JsonOptions = new()
    {
        PropertyNamingPolicy = JsonNamingPolicy.CamelCase,
        DefaultIgnoreCondition = System.Text.Json.Serialization.JsonIgnoreCondition.WhenWritingNull,
    };

    private readonly static ContainerRegistryClientOptions _ContainerRegistryOptions = new()
    {
        Audience = ContainerRegistryAudience.AzureResourceManagerPublicCloud
    };

    private readonly ILogger _Logger = logger;
    private readonly Uri _Uri = uri;
    private readonly TokenCredential _TokenCredential = tokenCredential;
    private ContainerRegistryClient? _ContainerRegistryClient;

    /// <summary>
    /// Fetch all tagged repository manifests that match the specified prefix.
    /// </summary>
    /// <param name="prefix">The path prefix of the repositories to fetch.</param>
    /// <param name="cancellationToken"></param>
    /// <returns></returns>
    public async Task<IEnumerable<PatternDescriptor>> FetchAsync(string? prefix, CancellationToken cancellationToken = default)
    {
        var client = GetRepositoryClient();
        var results = new List<PatternDescriptor>();

        prefix = string.IsNullOrWhiteSpace(prefix) ? null : prefix;

        await foreach (var name in client.GetRepositoryNamesAsync(cancellationToken).ConfigureAwait(false))
        {
            // Ignore repositories that do not start with the specified prefix.
            if (prefix != null && !name.StartsWith(prefix, StringComparison.Ordinal))
                continue;

            var repository = client.GetRepository(name);

            _Logger.LogDebug("Listing versions for repository {Name}.", name);

            await foreach (var version in repository.GetAllManifestPropertiesAsync(ArtifactManifestOrder.LastUpdatedOnDescending, cancellationToken).ConfigureAwait(false))
            {
                // Ignore untagged versions.
                if (version.Tags == null || version.Tags.Count == 0)
                    continue;

                foreach (var tag in version.Tags)
                {
                    _Logger.LogDebug($"Found tag: {tag} for repository {name}.");
                    results.Add(new PatternDescriptor
                    {
                        Name = name,
                        Digest = version.Digest,
                        Version = tag,
                    });
                }
            }
        }

        return results;
    }

    public async Task<PatternDescriptor?> PushAsync(PatternDescriptor descriptor, Pattern pattern, CancellationToken cancellationToken = default)
    {
        var client = GetContentClient(descriptor.Name);
        var blobDescriptor = await UploadPatternBlobAsync(client, pattern, cancellationToken).ConfigureAwait(false);
        var emptyConfigBlobDescriptor = await UploadEmptyConfigBlobAsync(client, cancellationToken).ConfigureAwait(false);

        var annotations = ImmutableDictionary.CreateBuilder<string, string>();
        annotations.Add(OciAnnotations.PatternTitle, pattern.Name);
        annotations.Add(OciAnnotations.PatternDescription, pattern.Description);

        var manifest = BinaryData.FromObjectAsJson(new OciManifest(
            schemaVersion: 2,
            mediaType: "application/vnd.oci.image.manifest.v1+json",
            artifactType: PatternMediaType,
            config: emptyConfigBlobDescriptor,
            layers: [blobDescriptor],
            annotations: annotations.ToImmutableDictionary()
        ), _JsonOptions);


        _Logger.LogDebug($"Pushing manifest to {_Uri.Host}/{descriptor.Name}:{descriptor.Version}.");
        var response = await client.SetManifestAsync(manifest, descriptor.Version, ManifestMediaType.OciImageManifest, cancellationToken).ConfigureAwait(false);

        if (response == null || response.Value == null)
        {
            _Logger.LogError($"Failed to push manifest for {_Uri.Host}/{descriptor.Name}:{descriptor.Version}.");
            return null;
        }

        return new PatternDescriptor
        {
            Name = descriptor.Name,
            Digest = response.Value.Digest,
            Version = descriptor.Version
        };
    }

    public async Task<Pattern?> PullAsync(PatternDescriptor descriptor, CancellationToken cancellationToken = default)
    {
        var client = GetContentClient(descriptor.Name);

        var manifestResponse = await client.GetManifestAsync(descriptor.Version, cancellationToken).ConfigureAwait(false);
        if (manifestResponse == null)
        {
            _Logger.LogError($"Failed to pull manifest for {_Uri.Host}/{descriptor.Name}:{descriptor.Version}.");
            return null;
        }

        var manifest = manifestResponse.Value.Manifest.ToObjectFromJson<OciManifest>(_JsonOptions);
        if (manifest == null)
        {
            throw new InvalidOperationException($"Failed to deserialize manifest for {_Uri.Host}/{descriptor.Name}:{descriptor.Version}");
        }

        // Find a pattern layer.
        foreach (var layer in manifest.Layers)
        {
            if (layer.MediaType == PatternLayerMediaType)
            {
                _Logger.LogDebug($"Downloading pattern layer {layer.Digest} for {_Uri.Host}/{descriptor.Name}:{descriptor.Version}.");

                var blobResponse = await client.DownloadBlobContentAsync(layer.Digest, cancellationToken).ConfigureAwait(false);
                if (blobResponse == null || blobResponse.Value == null)
                {
                    throw new InvalidOperationException($"Failed to download pattern blob {layer.Digest} for {_Uri.Host}/{descriptor.Name}:{descriptor.Version}");
                }

                var pattern = blobResponse.Value.Content.ToObjectFromJson<Pattern>(_JsonOptions);
                if (pattern == null)
                {
                    throw new InvalidOperationException($"Failed to deserialize pattern from blob {layer.Digest} for {_Uri.Host}/{descriptor.Name}:{descriptor.Version}");
                }

                return pattern;
            }
        }

        return null;
    }

    private async Task<OciDescriptor> UploadPatternBlobAsync(ContainerRegistryContentClient client, Pattern pattern, CancellationToken cancellationToken = default)
    {
        _Logger.LogDebug($"Uploading pattern blob for {pattern.Name}.");

        var blobData = BinaryData.FromObjectAsJson(pattern, _JsonOptions);
        var response = await client.UploadBlobAsync(blobData, cancellationToken).ConfigureAwait(false);

        if (response.Value.Digest == null)
        {
            throw new InvalidOperationException("Failed to upload pattern blob, digest is null.");
        }

        _Logger.LogDebug($"Uploaded pattern blob with digest {response.Value.Digest} and size {response.Value.SizeInBytes}.");

        return new OciDescriptor(response.Value.Digest, response.Value.SizeInBytes, PatternLayerMediaType);
    }

    private static async Task<OciDescriptor> UploadEmptyConfigBlobAsync(ContainerRegistryContentClient client, CancellationToken cancellationToken = default)
    {
        var response = await client.UploadBlobAsync(BinaryData.FromString("{}"), cancellationToken).ConfigureAwait(false);

        if (response.Value.Digest == null)
        {
            throw new InvalidOperationException("Failed to upload empty config blob, digest is null.");
        }

        return new OciDescriptor(response.Value.Digest, response.Value.SizeInBytes, "application/vnd.oci.empty.v1+json");
    }

    private ContainerRegistryContentClient GetContentClient(string repository)
    {
        return new ContainerRegistryContentClient(_Uri, repository, _TokenCredential, _ContainerRegistryOptions);
    }

    private ContainerRegistryClient GetRepositoryClient()
    {
        return _ContainerRegistryClient ??= new ContainerRegistryClient(_Uri, _TokenCredential, _ContainerRegistryOptions);
    }
}
