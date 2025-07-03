// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Arm.Policy;

/// <summary>
/// The type of a policy definition.
/// </summary>
public enum PolicyDefinitionResourceType
{
    /// <summary>
    /// An unknown policy definition type.
    /// </summary>
    Unknown = 0,

    /// <summary>
    /// A policy definition.
    /// </summary>
    PolicyDefinition,

    /// <summary>
    /// A policy set definition.
    /// </summary>
    PolicySetDefinition,
}
