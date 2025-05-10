// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Arm.Symbols;

#nullable enable

internal interface IDeploymentSymbol
{
    string Name { get; }

    DeploymentSymbolKind Kind { get; }

    void Configure(IResourceValue r);

    string? GetId(int index);
}

#nullable restore
