// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Linq;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Bicep.ThisNamespaceTestCases;

public sealed class BicepThisNamespaceTests : TemplateVisitorTestsBase
{
    [Fact]
    public void ProcessTemplate_WhenThisNamespaceUsed_ExpandsWithoutExistingState()
    {
        var resources = ProcessTemplate(GetSourcePath("Bicep/ThisNamespaceTestCases/Tests.Bicep.1.json"), null, out _);

        var storage = resources.Where(r => r["type"].Value<string>() == "Microsoft.Storage/storageAccounts").ToArray();
        Assert.Equal(2, storage.Length);
        for (var i = 0; i < storage.Length; i++)
        {
            Assert.Equal($"thisnamespacetest{i}", storage[i]["name"].Value<string>());
            Assert.Equal("test", storage[i]["tags"]["environment"].Value<string>());
            Assert.Equal("Standard_LRS", storage[i]["sku"]["name"].Value<string>());
            Assert.Equal("Cold", storage[i]["properties"]["accessTier"].Value<string>());
        }

        var network = Assert.Single(resources, r => r["type"].Value<string>() == "Microsoft.Network/virtualNetworks");
        Assert.Null(network["properties"]["addressSpace"]["addressPrefixes"]);
        Assert.Equal("256", network["properties"]["addressSpace"]["ipamPoolPrefixAllocations"][0]["numberOfIpAddresses"].Value<string>());

        var subnets = network["properties"]["subnets"].Value<JArray>();
        Assert.Equal(2, subnets.Count);
        Assert.Equal("App", subnets[0]["name"].Value<string>());
        Assert.Equal("functionApp", subnets[1]["name"].Value<string>());
        Assert.Equal("128", subnets[0]["properties"]["ipamPoolPrefixAllocations"][0]["numberOfIpAddresses"].Value<string>());
        Assert.Equal("32", subnets[1]["properties"]["ipamPoolPrefixAllocations"][0]["numberOfIpAddresses"].Value<string>());
        Assert.All(subnets, subnet => Assert.Null(subnet["properties"]["addressPrefixes"]));
    }
}
