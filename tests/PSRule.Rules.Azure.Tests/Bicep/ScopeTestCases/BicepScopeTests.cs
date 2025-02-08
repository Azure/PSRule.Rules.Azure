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

    [Fact]
    public void ProcessTemplate_WhenResourceGroupFromSubscriptionScope_ShouldReturnCorrectIdentifiers()
    {
        var resources = ProcessTemplate(GetSourcePath("Bicep/ScopeTestCases/Tests.Bicep.2.json"), null, out _);

        Assert.NotNull(resources);

        var actual = resources.Where(r => r["name"].Value<string>() == "rg-1").FirstOrDefault();
        Assert.Equal("Microsoft.Resources/resourceGroups", actual["type"].Value<string>());
        Assert.Equal("rg-1", actual["name"].Value<string>());
        Assert.Equal("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/rg-1", actual["id"].Value<string>());

        actual = resources.Where(r => r["name"].Value<string>() == "id-1").FirstOrDefault();
        Assert.Equal("id-1", actual["name"].Value<string>());
        Assert.Equal("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/rg-1/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-1", actual["id"].Value<string>());

        actual = resources.Where(r => r["name"].Value<string>() == "registry-1").FirstOrDefault();
        Assert.Equal("registry-1", actual["name"].Value<string>());
        Assert.Equal("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/rg-1/providers/Microsoft.ContainerRegistry/registries/registry-1", actual["id"].Value<string>());

        var property = actual["identity"]["userAssignedIdentities"].Value<JObject>().Properties().FirstOrDefault();
        Assert.Equal("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/rg-1/providers/Microsoft.ManagedIdentity/userAssignedIdentities/id-1", property.Name);
    }

    [Fact]
    public void ProcessTemplate_WhenTenantScope_ShouldReturnCorrectIdentifiers()
    {
        var resources = ProcessTemplate(GetSourcePath("Bicep/ScopeTestCases/Tests.Bicep.3.json"), null, out _);

        Assert.NotNull(resources);

        var actual = resources.Where(r => r["name"].Value<string>() == "mg-test").FirstOrDefault();
        Assert.Equal("Microsoft.Management/managementGroups", actual["type"].Value<string>());
        Assert.Equal("/providers/Microsoft.Management/managementGroups/mg-test", actual["id"].Value<string>());

        actual = resources.Where(r => r["name"].Value<string>() == "mg-test/00000000-0000-0000-0000-000000000000").FirstOrDefault();
        Assert.Equal("Microsoft.Management/managementGroups/subscriptions", actual["type"].Value<string>());
        Assert.Equal("/providers/Microsoft.Management/managementGroups/mg-test/subscriptions/00000000-0000-0000-0000-000000000000", actual["id"].Value<string>());
    }
}
