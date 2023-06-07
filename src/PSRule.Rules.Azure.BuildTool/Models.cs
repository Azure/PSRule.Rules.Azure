// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;

namespace PSRule.Rules.Azure.BuildTool
{
    internal sealed class IndexEntry
    {
        [JsonProperty(PropertyName = "r")]
        public string RelativePath { get; set; }

        [JsonProperty(PropertyName = "i")]
        public int Index { get; set; }
    }

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

    internal sealed class AvailabilityZoneMapping
    {
        public string Location { get; set; }

        public string[] Zones { get; set; }
    }

    /// <summary>
    /// A wrapper class for JSON minification.
    /// </summary>
    internal sealed class ResourceTypeMin
    {
        private readonly ResourceTypeEntry _Expanded;

        public ResourceTypeMin(ResourceTypeEntry resourceType)
        {
            _Expanded = resourceType;
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
