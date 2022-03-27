// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

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
            return str.Count(c => c == chr);
        }
    }
}