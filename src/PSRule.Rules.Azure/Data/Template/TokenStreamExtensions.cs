// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Linq;

namespace PSRule.Rules.Azure.Data.Template;

/// <summary>
/// Add an expression token to a token stream.
/// </summary>
internal static class TokenStreamExtensions
{
    private const string TOKEN_CURRENT = "current";
    private const string TOKEN_FIELD = "field";
    private const string TOKEN_CONCAT = "concat";
    private const string TOKEN_SPLIT = "split";

    internal static void Function(this TokenStream stream, string functionName)
    {
        stream.Add(new ExpressionToken(ExpressionTokenType.Element, functionName));
    }

    internal static void Numeric(this TokenStream stream, long value)
    {
        stream.Add(new ExpressionToken(value));
    }

    internal static void String(this TokenStream stream, string content)
    {
        stream.Add(new ExpressionToken(ExpressionTokenType.String, content));
    }

    internal static void Property(this TokenStream stream, string propertyName)
    {
        stream.Add(new ExpressionToken(ExpressionTokenType.Property, propertyName));
    }

    internal static void GroupStart(this TokenStream stream)
    {
        stream.Add(new ExpressionToken(ExpressionTokenType.GroupStart, null));
    }

    internal static void GroupEnd(this TokenStream stream)
    {
        stream.Add(new ExpressionToken(ExpressionTokenType.GroupEnd, null));
    }

    internal static void IndexStart(this TokenStream stream)
    {
        stream.Add(new ExpressionToken(ExpressionTokenType.IndexStart, null));
    }

    internal static void IndexEnd(this TokenStream stream)
    {
        stream.Add(new ExpressionToken(ExpressionTokenType.IndexEnd, null));
    }

    internal static bool ConsumeFunction(this TokenStream stream, string name)
    {
        if (stream == null ||
            stream.Count == 0 ||
            stream.Current.Type != ExpressionTokenType.Element ||
            !string.Equals(stream.Current.Content, name, StringComparison.OrdinalIgnoreCase))
            return false;

        stream.Pop();
        return true;
    }

    internal static bool ConsumePropertyName(this TokenStream stream, string propertyName)
    {
        if (stream == null ||
            stream.Count == 0 ||
            stream.Current.Type != ExpressionTokenType.Property ||
            !string.Equals(stream.Current.Content, propertyName, StringComparison.OrdinalIgnoreCase))
            return false;

        stream.Pop();
        return true;
    }

    internal static bool ConsumeString(this TokenStream stream, string s)
    {
        if (stream == null ||
            stream.Count == 0 ||
            stream.Current.Type != ExpressionTokenType.String ||
            !string.Equals(stream.Current.Content, s, StringComparison.OrdinalIgnoreCase))
            return false;

        stream.Pop();
        return true;
    }

    internal static bool ConsumeString(this TokenStream stream, out string s)
    {
        s = null;
        if (stream == null ||
            stream.Count == 0 ||
            stream.Current.Type != ExpressionTokenType.String)
            return false;

        s = stream.Current.Content;
        stream.Pop();
        return true;
    }

    internal static bool ConsumeInteger(this TokenStream stream, out int? i)
    {
        i = null;
        if (stream == null ||
            stream.Count == 0 ||
            stream.Current.Type != ExpressionTokenType.Numeric)
            return false;

        i = (int)stream.Current.Value;
        stream.Pop();
        return true;
    }

    internal static bool ConsumeGroup(this TokenStream stream)
    {
        if (stream == null ||
            stream.Count == 0 ||
            stream.Current.Type != ExpressionTokenType.GroupStart)
            return false;

        stream.SkipGroup();
        return true;
    }

    internal static bool HasFieldTokens(this TokenStream stream)
    {
        return stream.ToArray().Any(t =>
            t.Type == ExpressionTokenType.Element &&
            string.Equals(TOKEN_FIELD, t.Content, StringComparison.OrdinalIgnoreCase)
        );
    }

    internal static bool HasPolicyRuntimeTokens(this TokenStream stream)
    {
        return stream.ToArray().Any(t =>
            t.Type == ExpressionTokenType.Element &&
            (
                string.Equals(TOKEN_CURRENT, t.Content, StringComparison.OrdinalIgnoreCase) ||
                string.Equals(TOKEN_CONCAT, t.Content, StringComparison.OrdinalIgnoreCase) ||
                string.Equals(TOKEN_SPLIT, t.Content, StringComparison.OrdinalIgnoreCase)
            )
        );
    }
}
