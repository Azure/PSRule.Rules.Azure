// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Linq;

namespace PSRule.Rules.Azure.Data.Template
{
    /// <summary>
    /// A validator which checks a stream of tokens.
    /// </summary>
    internal static class TokenStreamValidator
    {
        /// <summary>
        /// Look for literal values or use of variables().
        /// </summary>
        public static bool HasLiteralValue(TokenStream stream)
        {
            var tokens = CollectToken(stream);
            var insecureTokens = tokens.Where(
                t => t.Type == ExpressionTokenType.String ||
                t.Type == ExpressionTokenType.Numeric ||
                IsFunction(t, "variables")
            ).Count();
            return insecureTokens > 0;
        }

        private static ExpressionToken[] CollectToken(TokenStream stream)
        {
            var list = new List<ExpressionToken>();
            while (stream.Count > 0)
                CollectToken(stream, list);

            return list.ToArray();
        }

        private static void CollectToken(TokenStream stream, IList<ExpressionToken> results)
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
            if (IsFunction(token, "parameters") || IsFunction(token, "variables"))
                stream.SkipGroup();

            results.Add(token);
        }

        private static bool IsFunction(ExpressionToken token, string name)
        {
            return token.Type == ExpressionTokenType.Element && string.Equals(token.Content, name, StringComparison.OrdinalIgnoreCase);
        }
    }
}
