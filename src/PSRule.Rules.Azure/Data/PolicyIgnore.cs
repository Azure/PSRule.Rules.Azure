// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data
{
    internal sealed class PolicyIgnoreResult
    {
        public PolicyIgnoreReason Reason { get; set; }

        public string Value { get; set; }
    }

    internal sealed class PolicyIgnoreEntry
    {
        [JsonProperty("i")]
        public string[] PolicyDefinitionIds { get; set; }

        [JsonProperty("r")]
        public PolicyIgnoreReason Reason { get; set; }

        [JsonProperty("v", NullValueHandling = NullValueHandling.Ignore)]
        public string Value { get; set; }
    }

    internal enum PolicyIgnoreReason
    {
        /// <summary>
        /// The policy is excluded because it was duplicated with an existing rule.
        /// </summary>
        Duplicate = 1,

        /// <summary>
        /// The policy is excluded because it is not testable or not applicable for IaC.
        /// </summary>
        NotApplicable = 2,

        /// <summary>
        /// An exclusion configured by the user.
        /// </summary>
        Configured = 3
    }

    internal sealed class PolicyIgnoreResultConverter : JsonConverter
    {
        public override bool CanConvert(Type objectType)
        {
            return objectType == typeof(Dictionary<string, PolicyIgnoreResult>);
        }

        public override object ReadJson(JsonReader reader, Type objectType, object existingValue, JsonSerializer serializer)
        {
            if (reader.TokenType != JsonToken.StartArray)
                return null;

            reader.Read();
            var result = new Dictionary<string, PolicyIgnoreResult>(StringComparer.OrdinalIgnoreCase);

            while (reader.TokenType != JsonToken.EndArray)
            {
                var entry = serializer.Deserialize<PolicyIgnoreEntry>(reader);
                for (var i = 0; i < entry.PolicyDefinitionIds.Length; i++)
                {
                    result[entry.PolicyDefinitionIds[i]] = new PolicyIgnoreResult
                    {
                        Reason = entry.Reason,
                        Value = entry.Value,
                    };
                }
                reader.Read();
            }
            return result;
        }

        public override void WriteJson(JsonWriter writer, object value, JsonSerializer serializer)
        {
            throw new NotImplementedException();
        }
    }
}
