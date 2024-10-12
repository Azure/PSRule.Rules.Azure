// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure;

#nullable enable

public sealed class ResourceHelperTests
{
    [Fact]
    public void IsResourceType()
    {
        Assert.True(ResourceHelper.IsResourceType("/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/microsoft.operationalinsights/workspaces/workspace001", "Microsoft.OperationalInsights/workspaces"));
        Assert.True(ResourceHelper.IsResourceType("/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-A", "Microsoft.Network/virtualNetworks"));
        Assert.True(ResourceHelper.IsResourceType("/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-A/subnets/GatewaySubnet", "Microsoft.Network/virtualNetworks/subnets"));
        Assert.False(ResourceHelper.IsResourceType("/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-A", "Microsoft.Network/virtualNetworks/subnets"));
        Assert.False(ResourceHelper.IsResourceType("/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/microsoft.operationalinsights/workspaces/workspace001", "Microsoft.Network/virtualNetworks"));
    }

    [Fact]
    public void TryResourceIdComponentsFromTypeName()
    {
        var resourceType = new string[]
        {
            "microsoft.operationalinsights/workspaces",
            "Microsoft.Network/virtualNetworks/subnets"
        };
        var resourceName = new string[]
        {
            "workspace001",
            "vnet-A/GatewaySubnet"
        };

        Assert.True(ResourceHelper.TryResourceIdComponents(resourceType[0], resourceName[0], out var resourceTypeComponents, out var nameComponents));
        Assert.Equal("microsoft.operationalinsights/workspaces", resourceTypeComponents[0]);
        Assert.Equal("workspace001", nameComponents[0]);

        Assert.True(ResourceHelper.TryResourceIdComponents(resourceType[1], resourceName[1], out resourceTypeComponents, out nameComponents));
        Assert.Equal("Microsoft.Network/virtualNetworks", resourceTypeComponents[0]);
        Assert.Equal("subnets", resourceTypeComponents[1]);
        Assert.Equal("vnet-A", nameComponents[0]);
        Assert.Equal("GatewaySubnet", nameComponents[1]);
    }

    [Fact]
    public void TryResourceIdComponentsFromResourceId()
    {
        var id = new string[]
        {
            "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/microsoft.operationalinsights/workspaces/workspace001",
            "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-A/subnets/GatewaySubnet",
            "Microsoft.Network/virtualNetworks/vnet-A",
            "Microsoft.Network/virtualNetworks/vnet-A/subnets/GatewaySubnet"
        };

        Assert.True(ResourceHelper.TryResourceIdComponents(id[0], out var subscriptionId, out var resourceGroupName, out string[] resourceTypeComponents, out string[] nameComponents));
        Assert.Equal("00000000-0000-0000-0000-000000000000", subscriptionId);
        Assert.Equal("rg-test", resourceGroupName);
        Assert.Equal("microsoft.operationalinsights/workspaces", resourceTypeComponents[0]);
        Assert.Equal("workspace001", nameComponents[0]);

        Assert.True(ResourceHelper.TryResourceIdComponents(id[1], out subscriptionId, out resourceGroupName, out resourceTypeComponents, out nameComponents));
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", subscriptionId);
        Assert.Equal("test-rg", resourceGroupName);
        Assert.Equal("Microsoft.Network/virtualNetworks", resourceTypeComponents[0]);
        Assert.Equal("subnets", resourceTypeComponents[1]);
        Assert.Equal("vnet-A", nameComponents[0]);
        Assert.Equal("GatewaySubnet", nameComponents[1]);

        Assert.True(ResourceHelper.TryResourceIdComponents(id[2], out _, out _, out resourceTypeComponents, out nameComponents));
        Assert.Equal("Microsoft.Network/virtualNetworks", resourceTypeComponents[0]);
        Assert.Equal("vnet-A", nameComponents[0]);

        Assert.True(ResourceHelper.TryResourceIdComponents(id[3], out _, out _, out resourceTypeComponents, out nameComponents));
        Assert.Equal("Microsoft.Network/virtualNetworks", resourceTypeComponents[0]);
        Assert.Equal("subnets", resourceTypeComponents[1]);
        Assert.Equal("vnet-A", nameComponents[0]);
        Assert.Equal("GatewaySubnet", nameComponents[1]);
    }

    [Fact]
    public void CombineResourceId()
    {
        var resourceType = new string[]
        {
            "microsoft.operationalinsights/workspaces",
            "Microsoft.Network/virtualNetworks/subnets",
            "Microsoft.KeyVault/vaults/providers/diagnosticSettings",
            "Microsoft.Insights/diagnosticSettings"
        };
        var resourceName = new string[]
        {
            "workspace001",
            "vnet-A/GatewaySubnet",
            "kv-bicep-app-002/Microsoft.Insights/service",
            "service"
        };
        var id = new string[]
        {
            "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/microsoft.operationalinsights/workspaces/workspace001",
            "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-A/subnets/GatewaySubnet",
            "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/kv-bicep-app-002/providers/Microsoft.Insights/diagnosticSettings/service",
            "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/test-rg"
        };
        var scope = "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/kv-bicep-app-002";

        Assert.Equal(id[0], ResourceHelper.CombineResourceId("00000000-0000-0000-0000-000000000000", "rg-test", resourceType[0], resourceName[0]));
        Assert.Equal(id[1], ResourceHelper.CombineResourceId("ffffffff-ffff-ffff-ffff-ffffffffffff", "test-rg", resourceType[1], resourceName[1]));
        Assert.Equal(id[2], ResourceHelper.CombineResourceId("ffffffff-ffff-ffff-ffff-ffffffffffff", "test-rg", resourceType[2], resourceName[2]));
        Assert.Equal(id[3], ResourceHelper.CombineResourceId("ffffffff-ffff-ffff-ffff-ffffffffffff", "test-rg", (string[])null, null));
        Assert.Equal(id[2], ResourceHelper.CombineResourceId("ffffffff-ffff-ffff-ffff-ffffffffffff", "test-rg", resourceType[3], resourceName[3], scope: scope));
    }

    [Fact]
    public void CombineResourceIdManagementGroup()
    {
        Assert.Equal("/providers/Microsoft.Management/managementGroups/mg1/providers/Microsoft.Authorization/policyAssignments/assignment1", ResourceHelper.CombineResourceId("mg1", new string[] { "Microsoft.Authorization/policyAssignments" }, new string[] { "assignment1" }));
    }

    [Theory]
    [InlineData("microsoft.operationalinsights/workspaces", "workspace001", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test")]
    [InlineData("Microsoft.Network/virtualNetworks/subnets", "vnet-A/GatewaySubnet", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-A")]
    [InlineData("Microsoft.KeyVault/vaults/providers/diagnosticSettings", "kv-bicep-app-002/Microsoft.Insights/service", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-bicep-app-002")]
    [InlineData("Microsoft.ServiceBus/namespaces/topics", "besubns/demo1", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.ServiceBus/namespaces/besubns")]
    public void GetParentResourceId(string resourceType, string resourceName, string parentId)
    {
        Assert.Equal(parentId, ResourceHelper.GetParentResourceId("00000000-0000-0000-0000-000000000000", "rg-test", resourceType, resourceName));
    }

    [Theory]
    [InlineData("microsoft.operationalinsights/workspaces", "workspace001", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/microsoft.operationalinsights/workspaces/workspace001")]
    [InlineData("Microsoft.Network/virtualNetworks/subnets", "vnet-A/GatewaySubnet", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-A/subnets/GatewaySubnet")]
    [InlineData("Microsoft.KeyVault/vaults/providers/diagnosticSettings", "kv-bicep-app-002/Microsoft.Insights/service", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.KeyVault/vaults/kv-bicep-app-002/providers/Microsoft.Insights/diagnosticSettings/service")]
    [InlineData("Microsoft.Authorization/roleAssignments", "00000000-0000-0000-0000-000000000001", "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff", "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/providers/Microsoft.Authorization/roleAssignments/00000000-0000-0000-0000-000000000001")]
    [InlineData("Microsoft.Authorization/policyDefinitions", "00000000-0000-0000-0000-000000000002", "/", "/providers/Microsoft.Authorization/policyDefinitions/00000000-0000-0000-0000-000000000002")]
    [InlineData("Microsoft.Network/virtualNetworks/subnets", "vnet-A/GatewaySubnet", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-A", "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/Microsoft.Network/virtualNetworks/vnet-A/subnets/GatewaySubnet")]
    public void ResourceId(string resourceType, string resourceName, string scopeId, string id)
    {
        Assert.Equal(id, ResourceHelper.ResourceId(resourceType, resourceName, scopeId));
    }

    [Theory]
    [InlineData("/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-1/providers/microsoft.operationalinsights/workspaces/workspace-1", null, null, "00000000-0000-0000-0000-000000000000", "rg-1", new string[] { "microsoft.operationalinsights/workspaces" }, new string[] { "workspace-1" })]
    [InlineData("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/rg-2/providers/Microsoft.Network/virtualNetworks/vnet-1/subnets/subnet-1", null, null, "ffffffff-ffff-ffff-ffff-ffffffffffff", "rg-2", new string[] { "Microsoft.Network/virtualNetworks", "subnets" }, new string[] { "vnet-1", "subnet-1" })]
    [InlineData("/providers/Microsoft.Management/managementGroups/mg-1", null, "mg-1", null, null, null, null)]
    [InlineData("/providers/Microsoft.Management/managementGroups/mg-2/providers/Microsoft.Authorization/policyAssignments/assignment-1", null, "mg-2", null, null, new string[] { "Microsoft.Authorization/policyAssignments" }, new string[] { "assignment-1" })]
    [InlineData("/", "/", null, null, null, null, null)]
    [InlineData("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/rg-3/providers/Microsoft.KeyVault/vaults/keyvault-1/providers/Microsoft.Insights/diagnosticSettings/service", null, null, "ffffffff-ffff-ffff-ffff-ffffffffffff", "rg-3", new string[] { "Microsoft.KeyVault/vaults", "providers", "diagnosticSettings" }, new string[] { "keyvault-1", "Microsoft.Insights", "service" })]
    [InlineData("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/rg-4", null, null, "ffffffff-ffff-ffff-ffff-ffffffffffff", "rg-4", null, null)]
    [InlineData("/providers/Microsoft.Authorization/policyDefinitions/policy-1", "/", null, null, null, new string[] { "Microsoft.Authorization/policyDefinitions" }, new string[] { "policy-1" })]
    [InlineData("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/rg-5/providers/Microsoft.KeyVault/vaults/keyvault-1/secrets/secret-1", null, null, "ffffffff-ffff-ffff-ffff-ffffffffffff", "rg-5", new string[] { "Microsoft.KeyVault/vaults", "secrets" }, new string[] { "keyvault-1", "secret-1" })]
    [InlineData("Microsoft.Network/virtualNetworks/vnet-A", null, null, null, null, new string[] { "Microsoft.Network/virtualNetworks" }, new string[] { "vnet-A" })]
    [InlineData("Microsoft.Network/virtualNetworks/vnet-A/subnets/GatewaySubnet", null, null, null, null, new string[] { "Microsoft.Network/virtualNetworks", "subnets" }, new string[] { "vnet-A", "GatewaySubnet" })]
    public void ResourceIdComponents(string id, string? tenant, string? managementGroup, string? subscriptionId, string? resourceGroup, string[]? resourceType, string[]? resourceName)
    {
        Assert.True(ResourceHelper.ResourceIdComponents(id, out var actualTenant, out var actualManagementGroup, out var actualSubscriptionId, out var actualResourceGroup, out var actualResourceType, out var actualResourceName));
        Assert.Equal(tenant, actualTenant);
        Assert.Equal(managementGroup, actualManagementGroup);
        Assert.Equal(subscriptionId, actualSubscriptionId);
        Assert.Equal(resourceGroup, actualResourceGroup);
        Assert.Equal(resourceType, actualResourceType);
        Assert.Equal(resourceName, actualResourceName);
    }

    [Theory]
    [InlineData(new string[] { "Microsoft.KeyVault/vaults" }, new string[] { "vault-1" }, 1)]
    [InlineData(new string[] { "Microsoft.KeyVault/vaults", "secrets" }, new string[] { "vault-1", "secret-1" }, 2)]
    [InlineData(new string[] { "Microsoft.KeyVault/vaults", "providers", "diagnosticSettings" }, new string[] { "vault-1", "Microsoft.Insights", "service" }, 2)]
    public void ResourceIdDepth(string[] resourceType, string[] resourceName, int depth)
    {
        Assert.Equal(depth, ResourceHelper.ResourceIdDepth(null, null, null, null, resourceType, resourceName));
    }
}

#nullable restore
