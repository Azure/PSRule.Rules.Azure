// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Data.Policy
{
    /// <summary>
    /// Defines an Azure Policy Definition represented as a PSRule rule.
    /// </summary>
    internal sealed class PolicyDefinition
    {
        public PolicyDefinition(string definitionId, string description, JObject value, string displayName)
        {
            DefinitionId = definitionId;
            Recommendation = description.ReplaceNewLineSeparator(replacement: "\n");
            Synopsis = description.ToFirstLine();
            Value = value;
            DisplayName = displayName;
            Parameters = new Dictionary<string, IParameterValue>(StringComparer.OrdinalIgnoreCase);
            Types = new List<string>();
        }

        /// <summary>
        /// The policy definition parameters
        /// </summary>
        public readonly IDictionary<string, IParameterValue> Parameters;

        /// <summary>
        /// The policy definition id.
        /// </summary>
        public string DefinitionId { get; set; }

        /// <summary>
        /// The name of the rule.
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// The synopsis of the rule.
        /// </summary>
        public string Synopsis { get; set; }

        /// <summary>
        /// The recommendation of the rule.
        /// </summary>
        public string Recommendation { get; set; }

        /// <summary>
        /// The display name of the rule.
        /// </summary>
        public string DisplayName { get; set; }

        /// <summary>
        /// The raw original policy definition.
        /// </summary>
        public JObject Value { get; set; }

        /// <summary>
        /// The spec condition for the rule.
        /// </summary>
        public JObject Condition { get; set; }

        /// <summary>
        /// The spec where pre-condition for the rule.
        /// </summary>
        public JObject Where { get; set; }

        /// <summary>
        /// The spec with pre-condition for the rule.
        /// </summary>
        public string[] With { get; set; }

        /// <summary>
        /// The spec type pre-condition for the rule.
        /// </summary>
        public List<string> Types { get; }

        /// <summary>
        /// An optional metadata category of the policy.
        /// </summary>
        public string Category { get; internal set; }

        /// <summary>
        /// An optional metadata version of the policy.
        /// </summary>
        public string Version { get; internal set; }

        internal void AddParameter(string name, ParameterType type, object value)
        {
            Parameters.Add(name, new SimpleParameterValue(name, type, value));
        }

        internal void AddParameter(IParameterValue value)
        {
            Parameters.Add(value.Name, value);
        }
    }
}
