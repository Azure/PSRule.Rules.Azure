// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Management.Automation;
using PSRule.Rules.Azure.Runtime;
using Xunit;

namespace PSRule.Rules.Azure
{
    public sealed class RuntimeHelperTests
    {
        [Fact]
        public void CompressExpression()
        {
            Assert.Equal("not an expression", Helper.CompressExpression("not an expression"));
            Assert.Equal("[[not an expression]", Helper.CompressExpression("[[not an expression]"));
            Assert.Equal("[null()]", Helper.CompressExpression("[null()]"));
            Assert.Equal("[parameters('vnetName')]", Helper.CompressExpression("[parameters( 'vnetName' )]"));
            Assert.Equal("[resourceGroup().location]", Helper.CompressExpression("[ resourceGroup( ).location ]"));
            Assert.Equal("[parameters('shares')[copyIndex()].name]", Helper.CompressExpression("[ parameters( 'shares')[ copyIndex()].name]"));
            Assert.Equal("[concat('route-',parameters('subnets')[copyIndex('routeIndex')].name)]", Helper.CompressExpression("[concat('route-', parameters('subnets')[copyIndex('routeIndex')].name)]"));
            Assert.Equal("[concat(split(parameters('addressPrefix')[0],'/')[0],'/27')]", Helper.CompressExpression("[concat(split(parameters('addressPrefix')[0], '/')[0], '/27')]"));
        }

        [Fact]
        public void IsTemplateExpression()
        {
            Assert.False(Helper.IsTemplateExpression("not an expression"));
            Assert.False(Helper.IsTemplateExpression("[[not an expression]"));
            Assert.True(Helper.IsTemplateExpression("[null()]"));
            Assert.True(Helper.IsTemplateExpression("[parameters( 'vnetName' )]"));
            Assert.True(Helper.IsTemplateExpression("[ resourceGroup( ).location ]"));
            Assert.True(Helper.IsTemplateExpression("[ parameters( 'shares')[ copyIndex()].name]"));
            Assert.True(Helper.IsTemplateExpression("[concat('route-', parameters('subnets')[copyIndex('routeIndex')].name)]"));
            Assert.True(Helper.IsTemplateExpression("[concat(split(parameters('addressPrefix')[0], '/')[0], '/27')]"));
        }

        [Fact]
        public void GetNetworkSecurityGroup()
        {
            var securityRules = new PSObject[]
            {
                NewSecurityRule(100, "Deny", "Outbound", destinationAddressPrefix: "VirtualNetwork", destinationPortRange: "3389"),
                NewSecurityRule(101, "Deny", "Outbound", destinationAddressPrefix: "*", destinationPortRange: "22"),
                NewSecurityRule(1000, "Allow", "Outbound", destinationAddressPrefix: "*", destinationPortRange: "*")
            };

            var eval = Helper.GetNetworkSecurityGroup(securityRules);
            Assert.False(eval.Outbound("virtualNetwork", 3389) == Data.Network.Access.Allow);
            Assert.False(eval.Outbound("virtualNetwork", 22) == Data.Network.Access.Allow);
            Assert.True(eval.Outbound("virtualNetwork", 80) == Data.Network.Access.Allow);
        }

        [Fact]
        public void CreateService()
        {
            var service = Helper.CreateService("1.0.0", 90);
            Assert.NotNull(service);
            Assert.Equal("1.0.0", service.Minimum);
            Assert.Equal(90, service.Timeout);

            service.WithAllowedLocations(null);
            Assert.True(service.IsAllowedLocation("eastus"));

            service.WithAllowedLocations(System.Array.Empty<string>());
            Assert.True(service.IsAllowedLocation("eastus"));

            service.WithAllowedLocations(new string[] { "westus" });
            Assert.True(service.IsAllowedLocation("westus"));
            Assert.False(service.IsAllowedLocation("eastus"));

            service.WithAllowedLocations(new string[] { "" });
            Assert.True(service.IsAllowedLocation("eastus"));
        }

        #region Helper methods

        private static PSObject NewSecurityRule(int priority, string access, string direction, string destinationAddressPrefix = null, string destinationPortRange = null)
        {
            var result = new PSObject();
            var properties = new PSObject();
            properties.Properties.Add(new PSNoteProperty("priority", priority));
            properties.Properties.Add(new PSNoteProperty("access", access));
            properties.Properties.Add(new PSNoteProperty("direction", direction));

            if (destinationAddressPrefix != null)
                properties.Properties.Add(new PSNoteProperty("destinationAddressPrefix", destinationAddressPrefix));

            if (destinationPortRange != null)
                properties.Properties.Add(new PSNoteProperty("destinationPortRange", destinationPortRange));

            result.Properties.Add(new PSNoteProperty("properties", properties));
            return result;
        }

        #endregion Helper methods
    }
}
