// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Diagnostics;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Arm.Symbols;

#nullable enable

[DebuggerDisplay("{Name}")]
internal abstract class DeploymentSymbol(string name)
{
    public string Name { get; } = name;

    internal static IDeploymentSymbol? NewArray(string name)
    {
        return name == null ? null : new ArrayDeploymentSymbol(name);
    }

    internal static IDeploymentSymbol? NewObject(string name, IResourceValue? resource = null)
    {
        return name == null ? null : new ObjectDeploymentSymbol(name, resource);
    }
}

#nullable restore
