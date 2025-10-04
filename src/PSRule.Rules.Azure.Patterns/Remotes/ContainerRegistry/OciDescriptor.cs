// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Immutable;
using System.Text.Json.Serialization;

namespace PSRule.Rules.Azure.Patterns.Remotes.ContainerRegistry;

/// <summary>
/// Represents an OCI descriptor for container registry artifacts.
/// </summary>
public class OciDescriptor
{
    /// <summary>
    /// Initializes a new instance of the <see cref="OciDescriptor"/> class.
    /// </summary>
    /// <param name="digest">The digest of the artifact.</param>
    /// <param name="size">The size of the artifact.</param>
    /// <param name="mediaType">The media type of the artifact.</param>
    /// <param name="annotations">Optional annotations for the artifact.</param>
    public OciDescriptor(string digest, long size, string mediaType, IDictionary<string, string>? annotations = null)
    {
        MediaType = mediaType;
        Annotations = annotations?.ToImmutableDictionary() ?? ImmutableDictionary<string, string>.Empty;
        Digest = digest;
        Size = size;
    }

    /// <summary>
    /// Initializes a new instance of the <see cref="OciDescriptor"/> class with JSON constructor.
    /// </summary>
    /// <param name="mediaType">The media type of the artifact.</param>
    /// <param name="digest">The digest of the artifact.</param>
    /// <param name="size">The size of the artifact.</param>
    /// <param name="annotations">Optional annotations for the artifact.</param>
    [JsonConstructor]
    public OciDescriptor(string mediaType, string digest, long size, ImmutableDictionary<string, string>? annotations)
    {
        MediaType = mediaType;
        Digest = digest;
        Size = size;
        Annotations = annotations ?? ImmutableDictionary<string, string>.Empty;
    }

    /// <summary>
    /// Gets the media type of the artifact.
    /// </summary>
    public string MediaType { get; }

    /// <summary>
    /// Gets the digest of the artifact.
    /// </summary>
    public string Digest { get; }

    /// <summary>
    /// Gets the size of the artifact.
    /// </summary>
    public long Size { get; }

    /// <summary>
    /// Gets the annotations for the artifact.
    /// </summary>
    public ImmutableDictionary<string, string> Annotations { get; }
}
