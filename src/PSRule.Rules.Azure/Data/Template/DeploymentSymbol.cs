// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template;

internal abstract class DeploymentSymbol(string name)
{
    public string Name { get; } = name;

    internal static IDeploymentSymbol NewArray(string name)
    {
        return name == null ? null : new ArrayDeploymentSymbol(name);
    }

    internal static IDeploymentSymbol NewObject(string name, ResourceValue resource = null)
    {
        return name == null ? null : new ObjectDeploymentSymbol(name, resource);
    }
}
