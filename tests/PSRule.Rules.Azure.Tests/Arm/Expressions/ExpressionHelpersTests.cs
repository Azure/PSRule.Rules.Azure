// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Arm.Expressions;

#nullable enable

/// <summary>
/// Unit tests for <see cref="ExpressionHelpers"/>.
/// </summary>
public sealed class ExpressionHelpersTests
{
    [Fact]
    public void TryArray()
    {
        Assert.True(ExpressionHelpers.TryArray(JToken.Parse("[ 1, 2, 3 ]"), out _));
        Assert.True(ExpressionHelpers.TryArray(new JArray(1, 2, 3), out _));
        Assert.True(ExpressionHelpers.TryArray(new int[] { 1, 2, 3 }, out _));
    }

    [Fact]
    public void GetUnique()
    {
        Assert.Equal("0b0d0856d2b1e9", ExpressionHelpers.GetUniqueString(["test", "123"]));
        Assert.Equal("0b0d0856d2b1e9", ExpressionHelpers.GetUniqueString(["test123"]));
        Assert.Equal("0b0d0856d2b1e9", ExpressionHelpers.GetUniqueString([null, "test", "123"]));
        Assert.Equal("9c7543ad4767e2", ExpressionHelpers.GetUniqueString(["test", "1234"]));
    }

    [Theory]
    [InlineData(null, null)]
    [InlineData("test", "test")]
    [InlineData("[test", "[test")]
    [InlineData("[test]", "[[test]")]
    [InlineData("[[test]", "[[test]")]
    public void WrapLiteralString_WhenEnclosed_ShouldAddEscape(string? value, string? expected)
    {
        Assert.Equal(expected, ExpressionHelpers.WrapLiteralString(value));
    }

    [Theory]
    [InlineData(null, null)]
    [InlineData("test", "test")]
    [InlineData("[test", "[test")]
    [InlineData("[test]", "[test]")]
    [InlineData("[[test]", "[test]")]
    public void UnwrapLiteralString_WhenEnclosed_ShouldRemoveEscape(string? value, string? expected)
    {
        Assert.Equal(expected, ExpressionHelpers.UnwrapLiteralString(value));
    }
}

#nullable restore
