// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Pipeline.Export;

namespace PSRule.Rules.Azure;

public sealed class ResourceExportVisitorTests
{
    [Fact]
    public async Task VisitAsync()
    {
        var context = new TestResourceExportContext();
        var visitor = new ResourceExpandVisitor();
        var resource = GetResourceObject("Microsoft.ContainerService/managedClusters");
        await visitor.VisitAsync(context, resource);

        Assert.Equal("rg-test", resource["resourceGroupName"].Value<string>());
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", resource["subscriptionId"].Value<string>());
        Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", resource["tenantId"].Value<string>());
    }

    [Fact]
    public async Task VisitAsync_StorageAccount_ListsDefenderForStorageSettings()
    {
        var context = new RecordingResourceExportContext();
        var visitor = new ResourceExpandVisitor();
        var resource = GetResourceObject("Microsoft.Storage/storageAccounts");

        // Set properties so the resource is not expanded, and omit kind so blob and file services are skipped.
        resource["properties"] = new JObject();

        await visitor.VisitAsync(context, resource);

        var request = Assert.Single(context.ListRequests, r => r.RequestUri.EndsWith("/providers/Microsoft.Security/DefenderForStorageSettings", StringComparison.OrdinalIgnoreCase));
        Assert.Equal("2025-09-01-preview", request.ApiVersion);
        Assert.True(request.IgnoreNotFound);
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
