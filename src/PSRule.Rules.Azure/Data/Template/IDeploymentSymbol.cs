// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template;

#nullable enable

internal interface IDeploymentSymbol
{
    string Name { get; }

    DeploymentSymbolKind Kind { get; }

    void Configure(IResourceValue r);

    string? GetId(int index);
}

#nullable restore
