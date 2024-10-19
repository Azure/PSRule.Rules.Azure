// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Bicep.ExtensibilityTestCases;

public sealed class BicepExtensibilityTests : TemplateVisitorTestsBase
{
    /// <summary>
    /// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3062
    /// </summary>
    [Fact]
    public void ProcessTemplate_WhenMicrosoftGraphType_ShouldIgnoreExtensibilityResources()
    {
        var resources = ProcessTemplate(GetSourcePath("Bicep/ExtensibilityTestCases/Tests.Bicep.1.json"), null, out _);

        Assert.Single(resources);

        var actual = resources[0];
        Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
        Assert.Equal("ps-rule-test-deployment", actual["name"].Value<string>());
    }
}
