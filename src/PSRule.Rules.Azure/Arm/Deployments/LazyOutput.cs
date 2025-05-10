// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Diagnostics;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;
using static PSRule.Rules.Azure.Arm.Mocks.Mock;

namespace PSRule.Rules.Azure.Arm.Deployments;

internal abstract partial class DeploymentVisitor
{
    [DebuggerDisplay("{_Name}, {_Type.Type}")]
    private sealed class LazyOutput : ILazyValue
    {
        private readonly string _Name;
        private readonly TemplateContext _Context;
        private readonly JObject _Value;
        private readonly ParameterType _Type;

        public LazyOutput(TemplateContext context, string name, JObject value)
        {
            _Context = context;
            _Name = name;
            _Value = value;
            if (!TryParameterType(context, value, out var type))
                throw ThrowTemplateOutputException(name);

            _Type = type.Value;
        }

        public object GetValue()
        {
            ResolveProperty(_Context, _Value, PROPERTY_VALUE);

            // Handle basic types.
            if (_Value.TryValueProperty(out var value) && _Type.Type == TypePrimitive.String && value.Type == JTokenType.String)
            {
                return _Value;
            }
            else if (value != null && _Type.Type == TypePrimitive.Bool && value.Type == JTokenType.Boolean)
            {
                return _Value;
            }
            else if (value != null && _Type.Type == TypePrimitive.Int && value.Type == JTokenType.Integer)
            {
                return _Value;
            }
            else if (value != null && _Type.Type == TypePrimitive.Array && _Type.ItemType == TypePrimitive.String && value.Type == JTokenType.Array)
            {
                return _Value;
            }
            else if (value != null && _Type.Type == TypePrimitive.Array && _Type.ItemType == TypePrimitive.Bool && value.Type == JTokenType.Array)
            {
                return _Value;
            }
            else if (value != null && _Type.Type == TypePrimitive.Array && _Type.ItemType == TypePrimitive.Int && value.Type == JTokenType.Array)
            {
                return _Value;
            }
            return new MockObject(_Value);
        }
    }
}
