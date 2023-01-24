// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Linq;

namespace PSRule.Rules.Azure
{
    internal static class StringExtensions
    {
        /// <summary>
        /// Convert the first character of the string to lower-case.
        /// </summary>
        internal static string ToCamelCase(this string str)
        {
            return !string.IsNullOrEmpty(str)
                ? char.ToLowerInvariant(str[0]) + str.Substring(1)
                : string.Empty;
        }

        /// <summary>
        /// Count the occurances of the specified character in the string.
        /// </summary>
        /// <param name="str">The original string.</param>
        /// <param name="chr">The character to count.</param>
        /// <returns>The number of occurances in the string.</returns>
        internal static int CountCharacterOccurrences(this string str, char chr)
        {
            return !string.IsNullOrEmpty(str)
                ? str.Count(c => c == chr)
                : 0;
        }

        /// <summary>
        /// Split by the last occurance of the specified substring.
        /// </summary>
        /// <param name="str">The original string to split.</param>
        /// <param name="substring">The substring to split by.</param>
        /// <returns>An array of left and right strings based on split.</returns>
        internal static string[] SplitByLastSubstring(this string str, string substring)
        {
            var lastSubstringIndex = str.LastIndexOf(substring, StringComparison.OrdinalIgnoreCase);
            var firstPart = str.Substring(0, lastSubstringIndex);
            var secondPart = str.Substring(lastSubstringIndex + substring.Length);
            return new string[] { firstPart, secondPart };
        }

        /// <summary>
        /// Split by the first occurance of the specified substring.
        /// </summary>
        /// <param name="str">The original string to split.</param>
        /// <param name="substring">The substring to split by.</param>
        /// <returns>An array of left and right strings based on split.</returns>
        internal static string[] SplitByFirstSubstring(this string str, string substring)
        {
            var firstSubstringIndex = str.IndexOf(substring, StringComparison.OrdinalIgnoreCase);
            var firstPart = str.Substring(0, firstSubstringIndex);
            var secondPart = str.Substring(firstSubstringIndex + substring.Length);
            return new string[] { firstPart, secondPart };
        }

        /// <summary>
        /// Split a string by a specified character and return the last segment.
        /// </summary>
        /// <param name="str">The original string to split.</param>
        /// <param name="c">The character to split by.</param>
        /// <returns>The last segment of the string.</returns>
        internal static string SplitLastSegment(this string str, char c)
        {
            var lastSubstringIndex = str.LastIndexOf(c);
            return str.Substring(lastSubstringIndex + 1);
        }

        /// <summary>
        /// Check if the string is an Azure Resource Manager expression.
        /// Expression use the <c>[function()]</c> syntax.
        /// </summary>
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
