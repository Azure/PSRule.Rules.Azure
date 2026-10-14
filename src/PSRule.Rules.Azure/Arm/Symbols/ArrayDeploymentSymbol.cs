// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Generic;
using PSRule.Rules.Azure.Arm.Deployments;

namespace PSRule.Rules.Azure.Arm.Symbols;

#nullable enable

/// <summary>
/// A symbol that represents an array of deployment resources.
/// </summary>
/// <param name="name"></param>
internal sealed class ArrayDeploymentSymbol(string name) : DeploymentSymbol(name), IDeploymentSymbol
{
    private List<string>? _Ids;
    private List<IResourceValue>? _Resources;

    public DeploymentSymbolKind Kind => DeploymentSymbolKind.Array;

    public void Configure(IResourceValue resource)
    {
        _Resources ??= [];
        _Resources.Add(resource);
        _Ids ??= [];
        _Ids.Add(TryResourceId(resource));
    }

    public string? GetId(int index)
    {
        return _Ids?[index];
    }

    public bool TryGetResource(int index, out IResourceValue? resource)
    {
        resource = _Resources != null && index >= 0 && index < _Resources.Count ? _Resources[index] : null;
        return resource != null;
    }

    public string[] GetIds()
    {
        return _Ids?.ToArray() ?? [];
    }

    public IResourceValue[] GetResources()
    {
        return _Resources?.ToArray() ?? [];
    }

    private static string TryResourceId(IResourceValue resource)
    {
        try
        {
            return resource.Id;
        }
        catch
        {
            return resource.SymbolicName;
        }
    }
}

#nullable restore
