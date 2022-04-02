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
    public sealed class PolicyAliasProvider
    {
        public IDictionary<string, PolicyAliasResourceType> Providers { get; }

        internal PolicyAliasProvider()
        {
            Providers = new Dictionary<string, PolicyAliasResourceType>(StringComparer.OrdinalIgnoreCase);
        }
    }

    public sealed class PolicyAliasResourceType
    {
        public IDictionary<string, PolicyAliasMapping> ResourceTypes { get; }

        internal PolicyAliasResourceType()
        {
            ResourceTypes = new Dictionary<string, PolicyAliasMapping>(StringComparer.OrdinalIgnoreCase);
        }
    }

    public sealed class PolicyAliasMapping
    {
        public IDictionary<string, string> AliasMappings { get; }

        internal PolicyAliasMapping()
        {
            AliasMappings = new Dictionary<string, string>(StringComparer.OrdinalIgnoreCase);
        }
    }

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

    internal sealed class PolicyDefinition
    {
        public string Id { get; set; }
        public string Name { get; set; }
        public string Description { get; set; }
        public string Effect { get; set; }
        public JObject Value { get; set; }
        public JObject Condition { get; set; }
        private readonly IDictionary<string, IParameterValue> _Parameters;

        public PolicyDefinition(string id, string name, string description, JObject value)
        {
            Id = id;
            Name = name;
            Description = description;
            Value = value;
            _Parameters = new Dictionary<string, IParameterValue>(StringComparer.OrdinalIgnoreCase);
        }

        internal void AddParameter(string name, ParameterType type, object value)
        {
            _Parameters.Add(name, new SimpleParameterValue(name, type, value));
        }

        internal void AddParameter(IParameterValue value)
        {
            _Parameters.Add(value.Name, value);
        }

        internal bool TryParameter(string parameterName, out IParameterValue value)
        {
            return _Parameters.TryGetValue(parameterName, out value);
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
                _Value = TemplateVisitor.ExpandProperty<T>(context, _LazyValue);
                _Resolved = true;
            }
            return _Value;
        }
    }
}