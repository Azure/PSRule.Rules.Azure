// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;
using System.Linq;

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
}
