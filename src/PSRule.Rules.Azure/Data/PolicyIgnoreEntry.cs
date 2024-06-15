// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data
{
    internal sealed class PolicyIgnoreEntry
    {
        [JsonProperty("i")]
        public string[] PolicyDefinitionIds { get; set; }

        [JsonProperty("r")]
        public PolicyIgnoreReason Reason { get; set; }

        [JsonProperty("v", NullValueHandling = NullValueHandling.Ignore)]
        public string Value { get; set; }
    }
}
