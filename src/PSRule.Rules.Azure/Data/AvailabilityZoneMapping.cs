// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data;

/// <summary>
/// An Azure Availability Zone mapping between location and zones.
/// </summary>
public sealed class AvailabilityZoneMapping
{
    /// <summary>
    /// The location/ region where AZ is available.
    /// </summary>
    [JsonProperty(PropertyName = "l")]
    public string Location { get; set; }

    /// <summary>
    /// The zone names available at the location.
    /// </summary>
    [JsonProperty(PropertyName = "z")]
    public string[] Zones { get; set; }
}
