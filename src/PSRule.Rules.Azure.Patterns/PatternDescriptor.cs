// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Patterns;

/// <summary>
/// Represents a descriptor for a pattern, including name, version, and digest.
/// </summary>
public sealed class PatternDescriptor
{
    /// <summary>
    /// Initializes a new instance of the <see cref="PatternDescriptor"/> class.
    /// </summary>
    public PatternDescriptor() { }

    /// <summary>
    /// Initializes a new instance of the <see cref="PatternDescriptor"/> class with the specified name and version.
    /// </summary>
    /// <param name="name">The name of the pattern.</param>
    /// <param name="version">The version of the pattern.</param>
    public PatternDescriptor(string name, string version)
    {
        Name = name;
        Version = version;
    }

    /// <summary>
    /// Gets or sets the digest of the pattern.
    /// </summary>
    public string? Digest { get; set; }

    /// <summary>
    /// Gets or sets the version of the pattern.
    /// </summary>
    public string? Version { get; set; }


    /// <summary>
    /// Gets or sets the name of the pattern.
    /// </summary>
    public string Name { get; set; }
}
