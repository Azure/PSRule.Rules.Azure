// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;
using static PSRule.Rules.Azure.Arm.Deployments.DeploymentVisitor;

namespace PSRule.Rules.Azure.Arm.Deployments;

internal sealed class LazyParameter<T>(TemplateContext context, string name, ParameterType type, JToken defaultValue) : ILazyValue, IParameterValue
{
    private readonly TemplateContext _Context = context;
    private readonly JToken _LazyValue = defaultValue;
    private T _Value;
    private bool _Resolved;

    public string Name { get; } = name;

    public ParameterType Type { get; } = type;

    public object GetValue()
    {
        if (!_Resolved)
        {
            _Value = _Context.ExpandToken<T>(_LazyValue);
            _Context.TrackSecureValue(Name, Type, _Value);
            _Resolved = true;
        }
        return _Value;
    }
}
