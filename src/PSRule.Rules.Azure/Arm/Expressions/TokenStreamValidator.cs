// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;

namespace PSRule.Rules.Azure.Arm.Expressions;

/// <summary>
/// A validator which checks a stream of tokens.
/// </summary>
internal static class TokenStreamValidator
{
    private const string FN_PARAMETERS = "parameters";
    private const string FN_VARIABLES = "variables";
    private const string FN_IF = "if";
    private const string FN_LIST = "list";
    private const string FN_REFERENCE = "reference";

    /// <summary>
    /// Look for literal values or use of variables().
    /// </summary>
    public static bool HasLiteralValue(TokenStream stream)
    {
        var tokens = CollectLiteralToken(stream);
        var insecureTokens = tokens.Where(
            t => t.Type == ExpressionTokenType.String ||
            t.Type == ExpressionTokenType.Numeric ||
            IsFunction(t, FN_VARIABLES)
        ).Count();
        return insecureTokens > 0;
    }

    /// <summary>
    /// Get the names of parameters that would be assigned as values.
    /// </summary>
    public static string[] GetParameterTokenValue(TokenStream stream)
    {
        var list = new List<string>();
        while (stream.Count > 0)
        {
            if (!stream.TryTokenType(ExpressionTokenType.Element, out var token))
            {
                stream.Pop();
                continue;
            }

            // Skip condition part of the if() since this a value is not set using any parameters specified here
            if (IsFunction(token, FN_IF))
            {
                stream.Skip(ExpressionTokenType.GroupStart);
                if (stream.TryTokenType(ExpressionTokenType.Element, out _))
                    stream.SkipGroup();
            }
            else if (TryParameters(stream, token, out var parameterName))
                list.Add(parameterName);
        }
        return [.. list];
    }

    /// <summary>
    /// Returns true if an expression contains a call to the list* function.
    /// </summary>
    public static bool UsesListFunction(TokenStream stream)
    {
        while (stream.Count > 0)
        {
            if (!stream.TryTokenType(ExpressionTokenType.Element, out var token))
            {
                stream.Pop();
                continue;
            }

            if (IsFunctionWithPrefix(token, FN_LIST) && !IsFunction(token, FN_LIST))
                return true;
        }
        return false;
    }

    /// <summary>
    /// Returns true if an expression contains a call to the reference function.
    /// </summary>
    public static bool UsesReferenceFunction(TokenStream stream)
    {
        while (stream.Count > 0)
        {
            if (!stream.TryTokenType(ExpressionTokenType.Element, out var token))
            {
                stream.Pop();
                continue;
            }

            if (IsFunction(token, FN_REFERENCE))
                return true;
        }
        return false;
    }

    private static bool TryParameters(TokenStream stream, ExpressionToken token, out string parameterName)
    {
        parameterName = null;
        if (!IsFunction(token, FN_PARAMETERS))
            return false;

        if (stream.Skip(ExpressionTokenType.GroupStart) &&
            stream.TryTokenType(ExpressionTokenType.String, out var nameToken) &&
            stream.Skip(ExpressionTokenType.GroupEnd))
            parameterName = nameToken.Content;

        return parameterName != null;
    }

    private static ExpressionToken[] CollectLiteralToken(TokenStream stream)
    {
        var list = new List<ExpressionToken>();
        while (stream.Count > 0)
            CollectLiteralToken(stream, list);

        return [.. list];
    }

    private static void CollectLiteralToken(TokenStream stream, IList<ExpressionToken> results)
    {
        if (stream.TryTokenType(ExpressionTokenType.Element, out var token))
            Element(stream, token, results);

        else if (stream.TryTokenType(ExpressionTokenType.String, out token) ||
            stream.TryTokenType(ExpressionTokenType.Numeric, out token))
            results.Add(token);

        else if (stream.TryTokenType(ExpressionTokenType.IndexStart, out _))
            SkipIndex(stream);

        else
            stream.Pop();
    }

    /// <summary>
    /// Skip index-based properties of an object or array.
    /// </summary>
    private static void SkipIndex(TokenStream stream)
    {
        var inner = 0;
        while (inner >= 0 && stream.Count > 0)
        {
            if (stream.Current.Type == ExpressionTokenType.IndexStart)
                inner++;

            if (stream.Current.Type == ExpressionTokenType.IndexEnd)
                inner--;

            stream.Pop();
        }
    }

    private static void Element(TokenStream stream, ExpressionToken token, IList<ExpressionToken> results)
    {
        // Ignore tokens inside parameters() and variables() which are not the actual value
        if (IsFunction(token, FN_PARAMETERS) || IsFunction(token, FN_VARIABLES))
            stream.SkipGroup();

        results.Add(token);
    }

    private static bool IsFunction(ExpressionToken token, string name)
    {
        return token.Type == ExpressionTokenType.Element &&
            string.Equals(token.Content, name, StringComparison.OrdinalIgnoreCase);
    }

    private static bool IsFunctionWithPrefix(ExpressionToken token, string prefix)
    {
        return token.Type == ExpressionTokenType.Element &&
            token.Content.StartsWith(prefix, StringComparison.OrdinalIgnoreCase);
    }
}
