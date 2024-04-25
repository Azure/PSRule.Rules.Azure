// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Converters;

namespace PSRule.Rules.Azure.BuildTool.Models
{
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
