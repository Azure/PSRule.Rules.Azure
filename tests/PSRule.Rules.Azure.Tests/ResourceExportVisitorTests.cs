// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Pipeline;
using PSRule.Rules.Azure.Pipeline.Export;
using Xunit;

namespace PSRule.Rules.Azure
{
    public sealed class ResourceExportVisitorTests
    {
        [Fact]
        public async Task VisitAsync()
        {
            var context = new TestResourceExportContext();
            var visitor = new ResourceExportVisitor();
            var resource = GetResourceObject("Microsoft.ContainerService/managedClusters");
            await visitor.VisitAsync(context, resource);

            Assert.Equal("rg-test", resource["resourceGroupName"].Value<string>());
            Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", resource["subscriptionId"].Value<string>());
            Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", resource["tenantId"].Value<string>());
        }

        private static JObject GetResourceObject(string resourceType)
        {
            return new JObject
            {
                { "type", resourceType },
                { "id", $"/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/rg-test/providers/{resourceType}/test" },
                { "tenantId", "ffffffff-ffff-ffff-ffff-ffffffffffff" }
            };
        }
    }

    internal sealed class TestResourceExportContext : ResourceExportContext
    {
        public TestResourceExportContext()
            : base(null, null, new AccessTokenCache(GetAccessToken), retryCount: 3, retryInterval: 10)
        {
            RefreshToken("ffffffff-ffff-ffff-ffff-ffffffffffff");
        }

        private static AccessToken GetAccessToken(string tenantId)
        {
            return new AccessToken(string.Empty, DateTime.UtcNow.AddMinutes(15), tenantId);
        }
    }
}
