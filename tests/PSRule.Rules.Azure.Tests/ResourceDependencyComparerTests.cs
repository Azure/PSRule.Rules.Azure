// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;
using Xunit;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

namespace PSRule.Rules.Azure
{
    public sealed class ResourceDependencyComparerTests
    {
        [Fact]
        public void SortWithComparer()
        {
            var context = new TemplateContext();
            var comparer = new ResourceDependencyComparer();
            var resources = new IResourceValue[]
            {
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/virtualNetworks\", \"name\": \"vnet-001\", \"dependsOn\": [ \"/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/routeTables/rt-001\", \"/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/routeTables/rt-002\" ] }")),
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/routeTables\", \"name\": \"rt-001\", \"dependsOn\": [ ] }")),
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/routeTables\", \"name\": \"rt-002\" }")),
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/virtualNetworks/subnets\", \"name\": \"vnet-001/subnet-001\", \"dependsOn\": [ \"/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/virtualNetworks/vnet-001\" ] }")),
            };
            Array.Sort(resources, comparer);

            var actual = resources[0];
            Assert.Equal("rt-001", actual.Value["name"].Value<string>());

            actual = resources[1];
            Assert.Equal("rt-002", actual.Value["name"].Value<string>());

            actual = resources[2];
            Assert.Equal("vnet-001", actual.Value["name"].Value<string>());

            actual = resources[3];
            Assert.Equal("vnet-001/subnet-001", actual.Value["name"].Value<string>());

            // https://github.com/Azure/PSRule.Rules.Azure/issues/2255
            resources = new IResourceValue[]
            {
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/virtualNetworks\", \"name\": \"vnet-001\", \"dependsOn\": [ \"/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/routeTables/rt-002\" ] }")),
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/routeTables\", \"name\": \"rt-001\", \"dependsOn\": [ ] }")),
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/routeTables\", \"name\": \"rt-002\" }")),
                GetResourceValue(context, JObject.Parse("{ \"type\": \"Microsoft.Network/virtualNetworks/subnets\", \"name\": \"vnet-001/subnet-001\", \"dependsOn\": [ \"/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/virtualNetworks/vnet-001\" ] }")),
            };
            Array.Sort(resources, comparer);

            actual = resources[0];
            Assert.Equal("rt-001", actual.Value["name"].Value<string>());

            actual = resources[1];
            Assert.Equal("rt-002", actual.Value["name"].Value<string>());

            actual = resources[2];
            Assert.Equal("vnet-001", actual.Value["name"].Value<string>());

            actual = resources[3];
            Assert.Equal("vnet-001/subnet-001", actual.Value["name"].Value<string>());
        }

        #region Helper methods

        private static IResourceValue GetResourceValue(TemplateContext context, JObject resource)
        {
            resource.TryGetProperty("name", out var name);
            resource.TryGetProperty("type", out var type);
            resource.TryGetDependencies(out var dependencies);
            var resourceId = ResourceHelper.CombineResourceId(context.Subscription.SubscriptionId, context.ResourceGroup.Name, type, name);
            return new ResourceValue(resourceId, name, type, resource, dependencies, null);
        }

        #endregion Helper methods
    }
}
