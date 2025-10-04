// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Patterns;

/// <summary>
/// Provides information about a pattern.
/// </summary>
public sealed class PatternInfo
{
    /// <summary>
    /// Gets or sets the name of the pattern.
    /// </summary>
    public string Name { get; set; } = string.Empty;

    /// <summary>
    /// Gets or sets the description of the pattern.
    /// </summary>
    public string Description { get; set; } = string.Empty;
}
