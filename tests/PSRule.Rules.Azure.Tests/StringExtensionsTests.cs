// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure;

#nullable enable

/// <summary>
/// Unit tests for <see cref="StringExtensions"/>.
/// </summary>
public sealed class StringExtensionsTests
{
    [Theory]
    [InlineData(null, false)]
    [InlineData("test", false)]
    [InlineData("[test]", true)]
    [InlineData("[[test]", false)]
    public void IsExpressionString_WhenExpression_ShouldReturnTrue(string? value, bool expected)
    {
        Assert.Equal(expected, StringExtensions.IsExpressionString(value));
    }
}

#nullable restore
