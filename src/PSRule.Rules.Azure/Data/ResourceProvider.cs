// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.Diagnostics;
using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data
{
    [DebuggerDisplay("{ResourceType}")]
    public sealed class ResourceProviderType
    {
        [JsonProperty(PropertyName = "a")]
        public IReadOnlyDictionary<string, string> Aliases { get; set; }

        [JsonProperty(PropertyName = "t")]
        public string ResourceType { get; set; }

        [JsonProperty(PropertyName = "l")]
        public string[] Locations { get; set; }

        [JsonProperty(PropertyName = "v")]
        public string[] ApiVersions { get; set; }

        [JsonProperty(PropertyName = "z")]
        public AvailabilityZoneMapping[] ZoneMappings { get; set; }
    }

    public sealed class AvailabilityZoneMapping
    {
        [JsonProperty(PropertyName = "l")]
        public string Location { get; set; }

        [JsonProperty(PropertyName = "z")]
        public string[] Zones { get; set; }
    }
}
