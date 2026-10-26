// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Linq;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Arm.Deployments;

namespace PSRule.Rules.Azure.Bicep.SymbolicNameTestCases;

public sealed class BicepSymbolicNameTests : TemplateVisitorTestsBase
{
    /// <summary>
    /// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/2922
    /// </summary>
    [Fact]
    public void ProcessTemplate_WhenReferencesUsed_ReturnsItems()
    {
        _ = ProcessTemplate(GetSourcePath("Bicep/SymbolicNameTestCases/Tests.Bicep.1.json"), null, out var templateContext);

        Assert.True(templateContext.RootDeployment.TryOutput("items", out JObject output));
        var items = output["value"].Value<JArray>();

        Assert.Equal("child-0", items[0].Value<string>());
        Assert.Equal("child-1", items[1].Value<string>());

        Assert.True(templateContext.RootDeployment.TryOutput("itemsAsString", out output));
        items = output["value"].Value<JArray>();

        Assert.Equal("child-0", items[0].Value<string>());
        Assert.Equal("child-1", items[1].Value<string>());
    }

    /// <summary>
    /// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/2917
    /// </summary>
    [Fact]
    public void ProcessTemplate_WhenConditionalExistingReference_IgnoresExpand()
    {
        var resources = ProcessTemplate(GetSourcePath("Bicep/SymbolicNameTestCases/Tests.Bicep.2.json"), null, out _);

        Assert.Equal(3, resources.Length);

        var actual = resources[0];
        Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
        Assert.Equal("ps-rule-test-deployment", actual["name"].Value<string>());

        actual = resources[1];
        Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
        Assert.Equal("child2", actual["name"].Value<string>());

        actual = resources[2];
        Assert.Equal("Microsoft.Authorization/roleAssignments", actual["type"].Value<string>());
        Assert.Equal("02041802-66a9-0a85-7330-8186e16422c7", actual["name"].Value<string>());
    }

    /// <summary>
    /// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3123
    /// </summary>
    [Fact]
    public void ProcessTemplate_WhenExistingReferenceNameUsesExpression_ShouldExpandExpression()
    {
        _ = ProcessTemplate(GetSourcePath("Bicep/SymbolicNameTestCases/Tests.Bicep.3.json"), null, out _);
    }

    /// <summary>
    /// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3129
    /// </summary>
    [Fact]
    public void ProcessTemplate_WhenExistingReferenceNameUsesExpression_nn()
    {
        _ = ProcessTemplate(GetSourcePath("Bicep/SymbolicNameTestCases/Tests.Bicep.4.json"), null, out var templateContext);

        Assert.True(templateContext.RootDeployment.TryOutput("ids", out JObject output));
        var actual = output["value"].Value<JArray>().Values<string>();

        Assert.Equal([
            "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Web/sites/example1-webapp",
            "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Web/sites/example2-webapp"
        ], actual);
    }

    /// <summary>
    /// A string sourced from an object typed module output must resolve to a string when
    /// passed into a nested deployment and consumed by <c>guid()</c>.
    /// </summary>
    [Fact]
    public void ProcessTemplate_WhenObjectOutputPropertyUsedInGuid_ShouldResolveUniqueNames()
    {
        var resources = ProcessTemplate(GetSourcePath("Bicep/SymbolicNameTestCases/Tests.Bicep.6.json"), null, out _);

        var actual = resources.Where(r => r["type"].Value<string>() == "Microsoft.Authorization/roleAssignments").ToArray();
        Assert.Equal(2, actual.Length);
        Assert.NotEqual(actual[0]["name"].Value<string>(), actual[1]["name"].Value<string>());

        // The role definition ID is sourced from an object typed output of a module deployed to a child management group.
        foreach (var assignment in actual)
        {
            Assert.StartsWith(
                "/providers/Microsoft.Management/managementGroups/mg-intermediate-root/providers/Microsoft.Authorization/roleDefinitions/",
                assignment["properties"]["roleDefinitionId"].Value<string>());
        }
        System.Console.WriteLine("DUMP0: " + actual[0].ToString());
    }
}
