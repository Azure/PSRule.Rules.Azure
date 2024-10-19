// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template;

internal interface IParameterValue
{
    string Name { get; }

    ParameterType Type { get; }

    object GetValue();
}
