// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Patterns;

/// <summary>
/// An organization specific pattern.
/// </summary>
public sealed class Pattern
{
    /// <summary>
    /// The name of the pattern.
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// The description of the pattern.
    /// </summary>
    public string Description { get; set; } = string.Empty;

    /// <summary>
    /// The markdown body of the pattern.
    /// </summary>
    public string Body { get; set; } = string.Empty;
}
