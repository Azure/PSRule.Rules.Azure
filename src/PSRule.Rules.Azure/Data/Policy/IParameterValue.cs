// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Policy;

internal interface IParameterValue
{
    string Name { get; }

    ParameterType Type { get; }

    object GetValue(PolicyAssignmentVisitor.PolicyAssignmentContext context);
}
