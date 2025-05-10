// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Arm.Deployments;

internal interface IParameterValue
{
    string Name { get; }

    ParameterType Type { get; }

    object GetValue();
}
