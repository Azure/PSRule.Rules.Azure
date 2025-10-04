// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Immutable;
using System.Text.Json.Serialization;

namespace PSRule.Rules.Azure.Patterns.Remotes.ContainerRegistry;

/// <summary>
/// Represents an OCI manifest for container registry artifacts.
/// </summary>
[method: JsonConstructor]
public class OciManifest(int schemaVersion, string? mediaType, string? artifactType, OciDescriptor config, ImmutableArray<OciDescriptor> layers, ImmutableDictionary<string, string> annotations)
{
    /// <summary>
    /// Gets the schema version of the manifest.
    /// </summary>
    public int SchemaVersion { get; } = schemaVersion;

    /// <summary>
    /// Gets the media type of the manifest.
    /// </summary>
    public string? MediaType { get; } = mediaType;

    /// <summary>
    /// Gets the artifact type of the manifest.
    /// </summary>
    public string? ArtifactType { get; } = artifactType;

    /// <summary>
    /// Gets the configuration descriptor.
    /// </summary>
    public OciDescriptor Config { get; } = config;

    /// <summary>
    /// Gets the layers of the manifest.
    /// </summary>
    public ImmutableArray<OciDescriptor> Layers { get; } = layers;

    /// <summary>
    /// Additional information provided through arbitrary metadata.
    /// </summary>
    public ImmutableDictionary<string, string> Annotations { get; } = annotations;
}
