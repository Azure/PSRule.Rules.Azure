// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Immutable;
using System.Text.Json.Serialization;

namespace PSRule.Rules.Azure.Patterns.Remotes.ContainerRegistry;

public class OciDescriptor
{
    public OciDescriptor(string digest, long size, string mediaType, IDictionary<string, string>? annotations = null)
    {
        MediaType = mediaType;
        Annotations = annotations?.ToImmutableDictionary() ?? ImmutableDictionary<string, string>.Empty;
        Digest = digest;
        Size = size;
    }

    [JsonConstructor]
    public OciDescriptor(string mediaType, string digest, long size, ImmutableDictionary<string, string>? annotations)
    {
        MediaType = mediaType;
        Digest = digest;
        Size = size;
        Annotations = annotations ?? ImmutableDictionary<string, string>.Empty;
    }

    public string MediaType { get; }
    public string Digest { get; }
    public long Size { get; }
    public ImmutableDictionary<string, string> Annotations { get; }
}
