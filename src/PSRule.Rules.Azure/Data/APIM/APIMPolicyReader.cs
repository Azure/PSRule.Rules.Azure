// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System.Text.RegularExpressions;
using System.Xml;

namespace PSRule.Rules.Azure.Data.APIM;

/// <summary>
/// A reader for APIM policy files.
/// </summary>
internal static class APIMPolicyReader
{
    // Create a regex pattern to match the `="@(` `)"` pairs.
    private static readonly Regex _Pattern = new(@"(?<=\=""\@\().*?(?=\)"")", RegexOptions.Singleline | RegexOptions.Compiled);

    /// <summary>
    /// Read the content of the policy file as XML.
    /// </summary>
    /// <remarks>
    /// This method automatically escapes quotes within policy expressions to ensure the XML is well-formed.
    /// </remarks>
    public static XmlReader ReadContent(string content)
    {
        // For each match replace `"` characters with `&quot;`.
        foreach (Match match in _Pattern.Matches(content))
        {
            content = content.Replace(match.Value, match.Value.Replace("\"", "&quot;"));
        }

        return XmlReader.Create(new StringReader(content));
    }
}
