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
    }
}
