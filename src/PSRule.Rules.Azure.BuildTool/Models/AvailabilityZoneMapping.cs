// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;

namespace PSRule.Rules.Azure.BuildTool.Models
{
    internal sealed class AvailabilityZoneMapping
    {
        public string Location { get; set; }

        public string[] Zones { get; set; }
    }

    /// <summary>
    /// A wrapper class for JSON minification.
    /// </summary>
    internal sealed class AvailabilityZoneMappingMin
    {
        [JsonProperty(PropertyName = "l")]
        public string Location { get; set; }

        [JsonProperty(PropertyName = "z")]
        public string[] Zones { get; set; }
    }
}
