// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure
{
    internal static class StringExtensions
    {
        public static string ToCamelCase(this string str)
        {
            return !string.IsNullOrEmpty(str)
                ? char.ToLowerInvariant(str[0]) + str.Substring(1)
                : string.Empty;
        }
    }
}