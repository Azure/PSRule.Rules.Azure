// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;
using Newtonsoft.Json;

namespace PSRule.Rules.Azure.Data.Policy
{
    [JsonConverter(typeof(PolicyBaselineConverter))]
    internal sealed class PolicyBaseline
    {
        public PolicyBaseline(string name, string description, IEnumerable<string> definitionRuleNames, IEnumerable<string> replacedRuleNames)
        {
            Name = name;
            Description = description;
            Include = Union(definitionRuleNames ?? Array.Empty<string>(), replacedRuleNames ?? Array.Empty<string>());
        }

        private static string[] Union(IEnumerable<string> definitionRuleNames, IEnumerable<string> replacedRuleNames)
        {
            return definitionRuleNames.Union(replacedRuleNames).ToArray();
        }

        public string Name { get; }

        public string Description { get; }

        public string[] Include { get; }
    }
}
