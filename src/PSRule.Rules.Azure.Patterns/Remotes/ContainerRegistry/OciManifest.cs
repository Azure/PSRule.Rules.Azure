// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Immutable;
using System.Text.Json.Serialization;

namespace PSRule.Rules.Azure.Patterns.Remotes.ContainerRegistry;

[method: JsonConstructor]
public class OciManifest(int schemaVersion, string? mediaType, string? artifactType, OciDescriptor config, ImmutableArray<OciDescriptor> layers, ImmutableDictionary<string, string> annotations)
{
    public int SchemaVersion { get; } = schemaVersion;

    public string? MediaType { get; } = mediaType;

    public string? ArtifactType { get; } = artifactType;

    public OciDescriptor Config { get; } = config;

    public ImmutableArray<OciDescriptor> Layers { get; } = layers;

    /// <summary>
    /// Additional information provided through arbitrary metadata.
    /// </summary>
    public ImmutableDictionary<string, string> Annotations { get; } = annotations;
}
