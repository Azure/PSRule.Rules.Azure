// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

namespace PSRule.Rules.Azure
{
    public sealed class DependencyMapTests
    {
        [Fact]
        public void SortWithComparer()
        {
            var context = new TemplateContext();
            var resources = new IResourceValue[]
            {
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/virtualNetworks\", \"name\": \"vnet-001\", \"dependsOn\": [ \"/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/routeTables/rt-001\", \"/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/routeTables/rt-002\" ] }")),
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/routeTables\", \"name\": \"rt-001\", \"dependsOn\": [ ] }")),
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/routeTables\", \"name\": \"rt-002\" }")),
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/virtualNetworks/subnets\", \"name\": \"vnet-001/subnet-001\", \"dependsOn\": [ \"/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/virtualNetworks/vnet-001\" ] }")),
            };
            resources = context.SortDependencies(resources);

            var actual = resources[0];
            Assert.Equal("rt-001", actual.Value["name"].Value<string>());

            actual = resources[1];
            Assert.Equal("rt-002", actual.Value["name"].Value<string>());

            actual = resources[2];
            Assert.Equal("vnet-001", actual.Value["name"].Value<string>());

            actual = resources[3];
            Assert.Equal("vnet-001/subnet-001", actual.Value["name"].Value<string>());

            // https://github.com/Azure/PSRule.Rules.Azure/issues/2255
            context = new TemplateContext();
            resources = new IResourceValue[]
            {
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/virtualNetworks\", \"name\": \"vnet-001\", \"dependsOn\": [ \"/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/routeTables/rt-002\" ] }")),
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/routeTables\", \"name\": \"rt-001\", \"dependsOn\": [ ] }")),
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/routeTables\", \"name\": \"rt-002\" }")),
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/virtualNetworks/subnets\", \"name\": \"vnet-001/subnet-001\", \"dependsOn\": [ \"/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/virtualNetworks/vnet-001\" ] }")),
            };
            resources = context.SortDependencies(resources);

            actual = resources[0];
            Assert.Equal("rt-002", actual.Value["name"].Value<string>());

            actual = resources[1];
            Assert.Equal("vnet-001", actual.Value["name"].Value<string>());

            actual = resources[2];
            Assert.Equal("rt-001", actual.Value["name"].Value<string>());

            actual = resources[3];
            Assert.Equal("vnet-001/subnet-001", actual.Value["name"].Value<string>());
        }

        [Fact]
        public void SortSymbolicNameWithComparer()
        {
            var context = new TemplateContext();
            var resources = new IResourceValue[]
            {
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/virtualNetworks\", \"name\": \"vnet-001\", \"dependsOn\": [ \"rt-002\" ] }"), symbolicName: "vnet-001"),
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/routeTables\", \"name\": \"rt-001\", \"dependsOn\": [ ] }"), symbolicName: "rt-001"),
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/routeTables\", \"name\": \"rt-002\" }"), symbolicName: "rt-002"),
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/virtualNetworks/subnets\", \"name\": \"vnet-001/subnet-001\", \"dependsOn\": [ \"vnet-001\" ] }"), symbolicName: "vnet-001/subnet-001"),
            };
            resources = context.SortDependencies(resources);

            var actual = resources[0];
            Assert.Equal("rt-002", actual.Value["name"].Value<string>());

            actual = resources[1];
            Assert.Equal("vnet-001", actual.Value["name"].Value<string>());

            actual = resources[2];
            Assert.Equal("rt-001", actual.Value["name"].Value<string>());

            actual = resources[3];
            Assert.Equal("vnet-001/subnet-001", actual.Value["name"].Value<string>());
        }

        #region Helper methods

        private static IResourceValue GetResourceValue(TemplateContext context, JObject resource, string symbolicName = null)
        {
            resource.TryGetProperty("name", out var name);
            resource.TryGetProperty("type", out var type);
            resource.TryGetDependencies(out var dependencies);
            var resourceId = ResourceHelper.CombineResourceId(context.Subscription.SubscriptionId, context.ResourceGroup.Name, type, name);
            var result = new ResourceValue(resourceId, name, type, symbolicName, resource, null);
            context.TrackDependencies(result, dependencies);
            return result;
        }

        #endregion Helper methods
    }
}
