// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;

namespace PSRule.Rules.Azure.BuildTool.Models
{
    /// <summary>
    /// This is the full class for deserializing un-minified resource type data.
    /// </summary>
    internal sealed class ResourceTypeEntry
    {
        public ResourceTypeEntry()
        {
            Min = new ResourceTypeMin(this);
        }

        [JsonProperty(PropertyName = "aliases")]
        public IDictionary<string, string> Aliases { get; set; }

        [JsonProperty(PropertyName = "resourceType")]
        public string ResourceType { get; set; }

        [JsonProperty(PropertyName = "apiVersions")]
        public string[] ApiVersions { get; set; }

        [JsonProperty(PropertyName = "locations")]
        public string[] Locations { get; set; }

        [JsonProperty(PropertyName = "zoneMappings")]
        public AvailabilityZoneMapping[] ZoneMappings { get; set; }

        [JsonIgnore]
        public ResourceTypeMin Min { get; }
    }

    /// <summary>
    /// A wrapper class for JSON minification.
    /// </summary>
    internal sealed class ResourceTypeMin
    {
        private readonly ResourceTypeEntry _Expanded;

        public ResourceTypeMin(ResourceTypeEntry entry)
        {
            _Expanded = entry;
        }

        [JsonProperty(PropertyName = "a")]
        public IDictionary<string, string> Aliases => _Expanded.Aliases;

        [JsonProperty(PropertyName = "t")]
        public string ResourceType => _Expanded.ResourceType;

        [JsonProperty(PropertyName = "v")]
        public string[] ApiVersions => _Expanded.ApiVersions;

        [JsonProperty(PropertyName = "l")]
        public string[] Locations => _Expanded.Locations;

        [JsonProperty(PropertyName = "z")]
        public AvailabilityZoneMappingMin[] ZoneMappings
        {
            get
            {
                return _Expanded.ZoneMappings?.Select(x => new AvailabilityZoneMappingMin { Location = x.Location, Zones = x.Zones }).ToArray();
            }
        }
    }
}
