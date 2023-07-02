// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Xunit;

namespace PSRule.Rules.Azure
{
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
                "Microsoft.KeyVault/vaults/providers/diagnosticSettings"
            };
            var resourceName = new string[]
            {
                "workspace001",
                "vnet-A/GatewaySubnet",
                "kv-bicep-app-002/Microsoft.Insights/service"
            };
            var id = new string[]
            {
                "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test/providers/microsoft.operationalinsights/workspaces/workspace001",
                "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-A/subnets/GatewaySubnet",
                "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/kv-bicep-app-002/providers/Microsoft.Insights/diagnosticSettings/service",
                "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/test-rg"
            };

            Assert.Equal(id[0], ResourceHelper.CombineResourceId("00000000-0000-0000-0000-000000000000", "rg-test", resourceType[0], resourceName[0]));
            Assert.Equal(id[1], ResourceHelper.CombineResourceId("ffffffff-ffff-ffff-ffff-ffffffffffff", "test-rg", resourceType[1], resourceName[1]));
            Assert.Equal(id[2], ResourceHelper.CombineResourceId("ffffffff-ffff-ffff-ffff-ffffffffffff", "test-rg", resourceType[2], resourceName[2]));
            Assert.Equal(id[3], ResourceHelper.CombineResourceId("ffffffff-ffff-ffff-ffff-ffffffffffff", "test-rg", (string[])null, null));
        }

        [Fact]
        public void GetParentResourceId()
        {
            var resourceType = new string[]
            {
                "microsoft.operationalinsights/workspaces",
                "Microsoft.Network/virtualNetworks/subnets",
                "Microsoft.KeyVault/vaults/providers/diagnosticSettings"
            };
            var resourceName = new string[]
            {
                "workspace001",
                "vnet-A/GatewaySubnet",
                "kv-bicep-app-002/Microsoft.Insights/service"
            };
            var id = new string[]
            {
                "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/rg-test",
                "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-A",
                "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/test-rg/providers/Microsoft.KeyVault/vaults/kv-bicep-app-002"
            };

            Assert.Equal(id[0], ResourceHelper.GetParentResourceId("00000000-0000-0000-0000-000000000000", "rg-test", resourceType[0], resourceName[0]));
            Assert.Equal(id[1], ResourceHelper.GetParentResourceId("ffffffff-ffff-ffff-ffff-ffffffffffff", "test-rg", resourceType[1], resourceName[1]));
            Assert.Equal(id[2], ResourceHelper.GetParentResourceId("ffffffff-ffff-ffff-ffff-ffffffffffff", "test-rg", resourceType[2], resourceName[2]));
        }
    }
}
