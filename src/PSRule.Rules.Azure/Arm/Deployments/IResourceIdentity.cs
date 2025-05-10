// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Arm.Deployments;

internal interface IResourceIdentity
{
    /// <summary>
    /// The identifier of the resource.
    /// </summary>
    public string Id { get; }

    /// <summary>
    /// The name of the resource.
    /// </summary>
    public string Name { get; }

    /// <summary>
    /// The symbolic name of the resource.
    /// </summary>
    public string SymbolicName { get; }
}
