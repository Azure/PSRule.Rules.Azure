// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Patterns;

/// <summary>
/// Tests for the <see cref="MarkdownHelpers"/> class.
/// </summary>
public sealed class MarkdownHelpersTests
{
    [Fact]
    public void GetFrontmatter_WhenValidMarkdown_ShouldReturnMetadata()
    {
        var markdown = "---\ndescription: Test Pattern\n---\n# Content";
        var frontmatter = MarkdownHelpers.GetFrontmatter<PatternDocumentMetadata>(markdown);

        Assert.NotNull(frontmatter);
        Assert.Equal("Test Pattern", frontmatter.Description);
    }

    [Fact]
    public void GetMarkdownContent_WhenValidMarkdown_ShouldReturnBody()
    {
        var markdown = "---\ndescription: Test Pattern\n---\n# Content";
        var content = MarkdownHelpers.GetMarkdownContent(markdown);

        Assert.Equal("# Content", content.Trim());
    }
}
