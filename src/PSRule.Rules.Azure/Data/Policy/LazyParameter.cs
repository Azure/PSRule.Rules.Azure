// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Data.Policy
{
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
                _Value = context.ExpandToken<T>(_LazyValue);
                _Resolved = true;
            }
            return _Value;
        }
    }
}
