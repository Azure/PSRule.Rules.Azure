// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Arm.Symbols;

#nullable enable

/// <summary>
/// A symbol that represents an array of deployment resources.
/// </summary>
/// <param name="name"></param>
internal sealed class ArrayDeploymentSymbol(string name) : DeploymentSymbol(name), IDeploymentSymbol
{
    private List<string>? _Ids;

    public DeploymentSymbolKind Kind => DeploymentSymbolKind.Array;

    public void Configure(IResourceValue resource)
    {
        _Ids ??= [];
        _Ids.Add(resource.Id);
    }

    public string? GetId(int index)
    {
        return _Ids?[index];
    }

    public string[] GetIds()
    {
        return _Ids?.ToArray() ?? [];
    }
}

#nullable restore
