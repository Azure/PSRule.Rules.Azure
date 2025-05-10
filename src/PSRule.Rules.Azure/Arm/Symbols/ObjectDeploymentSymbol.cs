// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using PSRule.Rules.Azure.Arm.Deployments;

namespace PSRule.Rules.Azure.Arm.Symbols;

#nullable enable

/// <summary>
/// A symbol that represents an single deployment resource.
/// </summary>
internal sealed class ObjectDeploymentSymbol : DeploymentSymbol, IDeploymentSymbol
{
    private Func<string>? _GetId;

    public ObjectDeploymentSymbol(string name, IResourceValue? resource)
        : base(name)
    {
        if (resource != null)
            Configure(resource);
    }

    public DeploymentSymbolKind Kind => DeploymentSymbolKind.Object;

    public void Configure(IResourceValue resource)
    {
        _GetId = () => resource.Id;
    }

    public string? GetId(int index)
    {
        return _GetId == null ? null : _GetId();
    }
}

#nullable restore
