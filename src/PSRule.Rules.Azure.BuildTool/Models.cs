// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace PSRule.Rules.Azure.BuildTool
{
    internal sealed class IndexEntry
    {
        [JsonProperty(PropertyName = "r")]
        public string RelativePath { get; set; }

        [JsonProperty(PropertyName = "i")]
        public int Index { get; set; }
    }

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

    internal enum PolicyIgnoreReason
    {
        Duplicate = 1,

        NotApplicable = 2,
    }

    internal sealed class PolicyIgnoreEntry
    {
        public PolicyIgnoreEntry()
        {
            Min = new PolicyIgnoreMin(this);
        }

        [JsonProperty(PropertyName = "policyDefinitionIds")]
        public string[] PolicyDefinitionIds { get; set; }

        [JsonProperty(PropertyName = "reason")]
        [JsonConverter(typeof(StringEnumConverter))]
        public PolicyIgnoreReason Reason { get; set; }

        [JsonProperty(PropertyName = "value")]
        public string Value { get; set; }

        [JsonIgnore]
        public PolicyIgnoreMin Min { get; }
    }

    /// <summary>
    /// A wrapper class for JSON minification.
    /// </summary>
    internal sealed class PolicyIgnoreMin
    {
        private readonly PolicyIgnoreEntry _Expanded;

        public PolicyIgnoreMin(PolicyIgnoreEntry entry)
        {
            _Expanded = entry;
        }

        [JsonProperty("i")]
        public string[] PolicyDefinitionIds => _Expanded.PolicyDefinitionIds;

        [JsonProperty("r")]
        public PolicyIgnoreReason Reason => _Expanded.Reason;

        [JsonProperty("v", NullValueHandling = NullValueHandling.Ignore)]
        public string Value => _Expanded.Reason == PolicyIgnoreReason.Duplicate ? _Expanded.Value : null;
    }
}
