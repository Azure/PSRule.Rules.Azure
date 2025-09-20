// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using YamlDotNet.Serialization;

namespace PSRule.Rules.Azure.Patterns;

/// <summary>
/// Metadata for a pattern document stored as front matter in a Markdown file.
/// </summary>
public sealed class PatternDocumentMetadata
{
    /// <summary>
    /// The description of the pattern.
    /// </summary>
    [YamlMember(Alias = "description")]
    public string Description { get; set; } = string.Empty;
}
