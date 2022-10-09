// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Data
{
    internal sealed class PolicyIgnoreData : ResourceLoader
    {
        private const string RESOURCE_PATH = "policy-ignore.min.json.deflated";

        /// <summary>
        /// Settings for JSON deserialization.
        /// </summary>
        private static readonly JsonSerializerSettings _Settings = new()
        {
            Converters = new List<JsonConverter>
            {
                new HashSetConverter(StringComparer.OrdinalIgnoreCase),
            }
        };
        private HashSet<string> _Index;

        internal HashSet<string> GetIndex()
        {
            _Index ??= ReadIndex(GetContent(RESOURCE_PATH));
            return _Index;
        }

        private static HashSet<string> ReadIndex(string content)
        {
            return JsonConvert.DeserializeObject<HashSet<string>>(content, _Settings) ?? throw new JsonException(PSRuleResources.PolicyIgnoreInvalid);
        }
    }
}
