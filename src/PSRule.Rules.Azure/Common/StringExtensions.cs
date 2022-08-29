// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Linq;

namespace PSRule.Rules.Azure
{
    internal static class StringExtensions
    {
        internal static string ToCamelCase(this string str)
        {
            return !string.IsNullOrEmpty(str)
                ? char.ToLowerInvariant(str[0]) + str.Substring(1)
                : string.Empty;
        }

        internal static int CountCharacterOccurrences(this string str, char chr)
        {
            return !string.IsNullOrEmpty(str)
                ? str.Count(c => c == chr)
                : 0;
        }

        internal static string[] SplitByLastSubstring(this string str, string substring)
        {
            var lastSubstringIndex = str.LastIndexOf(substring, StringComparison.OrdinalIgnoreCase);
            var firstPart = str.Substring(0, lastSubstringIndex);
            var secondPart = str.Substring(lastSubstringIndex + substring.Length);
            return new string[] { firstPart, secondPart };
        }

        internal static string SplitLastSegment(this string str, char c)
        {
            var lastSubstringIndex = str.LastIndexOf(c);
            return str.Substring(lastSubstringIndex + 1);
        }

        internal static bool IsExpressionString(this string str)
        {
            return str != null &&
                str.Length >= 5 && // [f()]
                str[0] == '[' &&
                str[1] != '[' &&
                str[str.Length - 1] == ']';
        }
    }
}
