// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using Newtonsoft.Json;
using Newtonsoft.Json.Converters;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Data.Policy
{
    [JsonConverter(typeof(StringEnumConverter))]
    internal enum ParameterType
    {
        String,

        Array,

        Object,

        Boolean,

        Integer,

        Float,

        DateTime
    }

    internal interface IParameterValue
    {
        string Name { get; }

        ParameterType Type { get; }

        object GetValue(PolicyAssignmentVisitor.PolicyAssignmentContext context);
    }

    internal sealed class SimpleParameterValue : IParameterValue
    {
        private readonly object _Value;

        public SimpleParameterValue(string name, ParameterType type, object value)
        {
            Name = name;
            Type = type;
            _Value = value;
        }

        public string Name { get; }

        public ParameterType Type { get; }

        public object GetValue(PolicyAssignmentVisitor.PolicyAssignmentContext context)
        {
            return _Value;
        }
    }

    /// <summary>
    /// Defines an Azure Policy Definition represented as a PSRule rule.
    /// </summary>
    internal sealed class PolicyDefinition
    {
        public PolicyDefinition(string definitionId, string description, JObject value, string displayName)
        {
            DefinitionId = definitionId;
            Description = description;
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
        public string Description { get; set; }

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

    internal interface ILazyValue
    {
        object GetValue(PolicyAssignmentVisitor.PolicyAssignmentContext context);
    }

    internal sealed class LazyParameter<T> : ILazyValue, IParameterValue
    {
        private readonly JToken _LazyValue;
        private T _Value;
        private bool _Resolved;

        public LazyParameter(string name, ParameterType type, JToken defaultValue)
        {
            Name = name;
            Type = type;
            _LazyValue = defaultValue;
        }

        public string Name { get; }

        public ParameterType Type { get; }

        public object GetValue(PolicyAssignmentVisitor.PolicyAssignmentContext context)
        {
            if (!_Resolved)
            {
                _Value = TemplateVisitor.ExpandToken<T>(context, _LazyValue);
                _Resolved = true;
            }
            return _Value;
        }
    }
}
