// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.Diagnostics;
using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data;

/// <summary>
/// An Azure Resource Type.
/// </summary>
[DebuggerDisplay("{ResourceType}")]
public sealed class ResourceProviderType
{
    /// <summary>
    /// A list of policy aliases for the resource provider.
    /// </summary>
    [JsonProperty(PropertyName = "a")]
    public IReadOnlyDictionary<string, string> Aliases { get; set; }

    /// <summary>
    /// The resource type name.
    /// </summary>
    [JsonProperty(PropertyName = "t")]
    public string ResourceType { get; set; }

    /// <summary>
    /// An array of locations/ regions for the resource provider.
    /// </summary>
    [JsonProperty(PropertyName = "l")]
    public string[] Locations { get; set; }

    /// <summary>
    /// An array of valid API versions for the resource provider.
    /// </summary>
    [JsonProperty(PropertyName = "v")]
    public string[] ApiVersions { get; set; }

    /// <summary>
    /// An array of Availability Zone mappings for the resource provider.
    /// </summary>
    [JsonProperty(PropertyName = "z")]
    public AvailabilityZoneMapping[] ZoneMappings { get; set; }
}
