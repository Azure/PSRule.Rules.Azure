// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.ComponentModel;

namespace PSRule.Rules.Azure.Configuration;

/// <summary>
/// Options for generating and formatting output.
/// </summary>
public sealed class OutputOption : IEquatable<OutputOption>
{
    private const OutputEncoding DEFAULT_ENCODING = OutputEncoding.Default;

    internal static readonly OutputOption Default = new()
    {
        Encoding = DEFAULT_ENCODING
    };

    /// <summary>
    /// Create an empty output option.
    /// </summary>
    public OutputOption()
    {
        Encoding = null;
        Path = null;
    }

    /// <summary>
    /// Create a output option based on an existing option.
    /// </summary>
    public OutputOption(OutputOption option)
    {
        if (option == null)
            throw new ArgumentNullException(nameof(option));

        Encoding = option.Encoding;
        Path = option.Path;
    }

    /// <inheritdoc/>
    public override bool Equals(object obj)
    {
        return obj is OutputOption option && Equals(option);
    }

    /// <inheritdoc/>
    public bool Equals(OutputOption other)
    {
        return other != null &&
            Encoding == other.Encoding &&
            Path == other.Path;
    }

    /// <inheritdoc/>
    public override int GetHashCode()
    {
        unchecked // Overflow is fine
        {
            var hash = 17;
            hash = hash * 23 + (Encoding.HasValue ? Encoding.Value.GetHashCode() : 0);
            hash = hash * 23 + (Path != null ? Path.GetHashCode() : 0);
            return hash;
        }
    }

    internal static OutputOption Combine(OutputOption o1, OutputOption o2)
    {
        var result = new OutputOption(o1)
        {
            Path = o1.Path ?? o2.Path
        };
        return result;
    }

    /// <summary>
    /// The encoding to use when writing results to file.
    /// </summary>
    [DefaultValue(null)]
    public OutputEncoding? Encoding { get; set; }

    /// <summary>
    /// The file path location to save results.
    /// </summary>
    [DefaultValue(null)]
    public string Path { get; set; }
}
