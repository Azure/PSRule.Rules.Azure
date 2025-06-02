// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data;

/// <summary>
/// An Azure location.
/// Currently this is only physical locations that have availability zones.
/// </summary>
public sealed class AzureLocationEntry
{
    /// <summary>
    /// The number of physical zones available in the location.
    /// </summary>
    [JsonProperty("zones")]
    public int Zones { get; set; }
}
