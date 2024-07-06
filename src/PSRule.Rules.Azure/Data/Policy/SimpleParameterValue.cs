// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Policy
{
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
}
