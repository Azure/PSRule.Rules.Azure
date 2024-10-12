// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Policy;

internal sealed class SimpleParameterValue(string name, ParameterType type, object value) : IParameterValue
{
    private readonly object _Value = value;

    public string Name { get; } = name;

    public ParameterType Type { get; } = type;

    public object GetValue(PolicyAssignmentVisitor.PolicyAssignmentContext context)
    {
        return _Value;
    }
}
