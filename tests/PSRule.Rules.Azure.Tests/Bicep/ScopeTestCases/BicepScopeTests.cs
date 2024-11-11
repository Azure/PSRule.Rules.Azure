// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Linq;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Bicep.ScopeTestCases;

/// <summary>
/// Tests for validating resource scopes and IDs are generated correctly.
/// </summary>
public sealed class BicepScopeTests : TemplateVisitorTestsBase
{
    [Fact]
    public void ProcessTemplate_WhenManagementGroupAtTenant_ShouldReturnCompleteProperties()
    {
        var resources = ProcessTemplate(GetSourcePath("Bicep/ScopeTestCases/Tests.Bicep.1.json"), null, out _);

        Assert.NotNull(resources);

        var actual = resources.Where(r => r["name"].Value<string>() == "mg-01").FirstOrDefault();
        Assert.Equal("Microsoft.Management/managementGroups", actual["type"].Value<string>());
        Assert.Equal("/providers/Microsoft.Management/managementGroups/mg-01", actual["id"].Value<string>());
        Assert.Equal("/", actual["scope"].Value<string>());
        Assert.Equal("mg-01", actual["properties"]["displayName"].Value<string>());
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual["properties"]["tenantId"].Value<string>());

        actual = resources.Where(r => r["name"].Value<string>() == "mg-02").FirstOrDefault();
        Assert.Equal("Microsoft.Management/managementGroups", actual["type"].Value<string>());
        Assert.Equal("/providers/Microsoft.Management/managementGroups/mg-02", actual["id"].Value<string>());
        Assert.Equal("/", actual["scope"].Value<string>());
        Assert.Equal("mg-02", actual["properties"]["displayName"].Value<string>());
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual["properties"]["tenantId"].Value<string>());
        Assert.Equal("/providers/Microsoft.Management/managementGroups/mg-01", actual["properties"]["details"]["parent"]["id"].Value<string>());
    }
}
