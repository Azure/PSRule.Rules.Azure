// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Xml;
using PSRule.Rules.Azure.Data.APIM;

namespace PSRule.Rules.Azure.APIM;

/// <summary>
/// Test cases for APIM policy files with complex syntax.
/// </summary>
public sealed class APIMPolicyTests : BaseTests
{
    /// <summary>
    /// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3184
    /// </summary>
    [Fact]
    public void APIMPolicyReader_WhenExpressionIsFound_ShouldEscapeAndLoad()
    {
        using var reader = ReadContentFromFile("APIM/Tests.Policy.1.xml");

        var doc = new XmlDocument();
        doc.Load(reader);

        var node = doc.SelectSingleNode("//set-variable");

        Assert.Equal("@(context.Request.Headers.GetValueOrDefault(\"X-Original-Host\", \"NotAvailable\"))", node.Attributes["value"].Value);
    }

    #region Helper methods

    private static XmlReader ReadContentFromFile(string fileName)
    {
        var content = GetContent(fileName);
        return APIMPolicyReader.ReadContent(content);
    }

    #endregion Helper methods
}
