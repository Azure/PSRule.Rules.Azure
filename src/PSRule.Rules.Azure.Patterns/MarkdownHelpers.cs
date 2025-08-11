// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using YamlDotNet.Serialization;

namespace PSRule.Rules.Azure.Patterns;

/// <summary>
/// Provides helper methods for working with markdown content.
/// </summary>
internal static class MarkdownHelpers
{
    private static readonly IDeserializer _YamlDeserializer = new DeserializerBuilder()
        .IgnoreUnmatchedProperties()
        .Build();

    /// <summary>
    /// Extracts the front matter from a markdown string.
    /// </summary>
    public static T? GetFrontmatter<T>(string? markdown)
    {
        if (markdown == null || !markdown.StartsWith("---"))
            return default;

        var parts = markdown.Split(["---"], StringSplitOptions.RemoveEmptyEntries);

        return _YamlDeserializer.Deserialize<T>(parts[0]);
    }

    /// <summary>
    /// Get all the markdown content excluding the front matter.
    /// </summary>
    public static string? GetMarkdownContent(string? markdown)
    {
        if (markdown == null || !markdown.StartsWith("---"))
            return markdown;

        var parts = markdown.Split(["---"], StringSplitOptions.RemoveEmptyEntries);

        return string.Join("\n---\n", parts.Skip(1));
    }
}
