// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data
{
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
                    if (!result.TryGetValue(entry.PolicyDefinitionIds[i], out var ignoreResult))
                    {
                        ignoreResult = new PolicyIgnoreResult
                        {
                            Reason = entry.Reason,
                            Value = new List<string>()
                        };
                        result.Add(entry.PolicyDefinitionIds[i], ignoreResult);
                    }
                    ignoreResult.Value.Add(entry.Value);
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
