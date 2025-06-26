// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Linq;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Arm.Deployments;

namespace PSRule.Rules.Azure.Bicep.AVMTestCases;

public sealed class BicepAVMTests : TemplateVisitorTestsBase
{
    /// <summary>
    /// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3153
    /// </summary>
    [Fact]
    public void ProcessTemplate_WhenMappingOutputResourceId_ShouldReturnStringArray()
    {
        var resources = ProcessTemplate(GetSourcePath("Bicep/AVMTestCases/Tests.Bicep.1.json"), null, out var templateContext);

        Assert.Equal(6, resources.Length);

        // Checks ids is a unioned string array.
        Assert.True(templateContext.RootDeployment.TryOutput("ids", out JObject output));
        var ids = output["value"].Values<string>().ToArray();

        Assert.Equal([
            "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/networkInterfaces/pe.nic.f7cffe814cb5cd",
            "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/networkInterfaces/nic1"
        ], ids);

        // Check id is a string array.
        Assert.True(templateContext.RootDeployment.TryOutput("id", out output));
        var id = output["value"].Values<string>().ToArray();

        Assert.Equal([
            "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/networkInterfaces/nic1"
        ], id);
    }

    [Fact]
    public void ProcessTemplate_WhenReferencingCrossModuleDependency_ShouldGetResource()
    {
        var resources = ProcessTemplate(GetSourcePath("Bicep/AVMTestCases/Tests.Bicep.2.json"), null, out var templateContext);

        var actual = resources.FirstOrDefault(r => r["name"].Value<string>() == "site1");
        Assert.NotNull(actual);

        var endpoint = actual["properties"]["siteConfig"]["appSettings"].ToArray().FirstOrDefault(setting => setting["name"].Value<string>() == "endpoint");
        Assert.NotNull(endpoint);
        Assert.Equal("https://storage1.blob.core.windows.net/", endpoint["value"].Value<string>());
    }

    [Fact]
    public void ProcessTemplate_WhenReferencingDependencyThroughSecureOutputs_ShouldGetResource()
    {
        var resources = ProcessTemplate(GetSourcePath("Bicep/AVMTestCases/Tests.Bicep.3.json"), null, out var templateContext);

        var actual = resources.FirstOrDefault(r => r["name"].Value<string>() == "test-app-config");
        Assert.NotNull(actual);

        var subResources = actual["resources"].Values<JObject>().OfType<JObject>();
        Assert.NotNull(subResources);

        var connection = subResources.Where(r => r["name"].Value<string>() == "test-app-config/CONNECTION").FirstOrDefault();
        Assert.NotNull(connection);
        Assert.Equal("{{Secret}}", connection["properties"]["value"].Value<string>());

        var endpoint = subResources.Where(r => r["name"].Value<string>() == "test-app-config/ENDPOINT").FirstOrDefault();
        Assert.NotNull(endpoint);
        Assert.Equal("https://test-cosmosdb.documents.azure.com:443/", endpoint["properties"]["value"].Value<string>());
    }
}
