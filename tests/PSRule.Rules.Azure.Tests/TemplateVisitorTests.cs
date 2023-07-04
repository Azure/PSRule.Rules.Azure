// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Linq;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Pipeline;
using Xunit;
using static PSRule.Rules.Azure.Data.Template.TemplateVisitor;

namespace PSRule.Rules.Azure
{
    public sealed class TemplateVisitorTests
    {
        [Fact]
        public void ResolveTemplateTest()
        {
            var resources = ProcessTemplate(GetSourcePath("Resources.Template.json"), GetSourcePath("Resources.Parameters.json"));
            Assert.NotNull(resources);
            Assert.Equal(8, resources.Length);

            var actual = resources[0];
            Assert.True(actual["rootDeployment"].Value<bool>());

            actual = resources[1];
            Assert.Equal("route-subnet1", actual["name"].Value<string>());

            actual = resources[2];
            Assert.Equal("route-subnet2", actual["name"].Value<string>());

            actual = resources[3];
            Assert.Equal("nsg-subnet1", actual["name"].Value<string>());

            actual = resources[4];
            Assert.Equal("nsg-subnet2", actual["name"].Value<string>());

            actual = resources[5];
            Assert.Equal("nsg-extra", actual["name"].Value<string>());

            actual = resources[6];
            Assert.Equal("vnet-001", actual["name"].Value<string>());
            Assert.Equal("10.1.0.0/24", actual["properties"]["addressSpace"]["addressPrefixes"][0].Value<string>());
            Assert.Equal(3, actual["properties"]["subnets"].Value<JArray>().Count);
            Assert.Equal("10.1.0.32/28", actual["properties"]["subnets"][1]["properties"]["addressPrefix"].Value<string>());
            Assert.Equal("Networking", actual["tags"]["role"].Value<string>());
            Assert.Equal("region-A", actual["location"].Value<string>());
            var subResources = actual["resources"].Value<JArray>();
            actual = subResources[0] as JObject;
            Assert.Equal("vnet-001/subnet2", actual["name"].Value<string>());
            Assert.Equal("vnetDelegation", actual["properties"]["delegations"][0]["name"].Value<string>());
            actual = subResources[1] as JObject;
            Assert.Equal("vnet-001/subnet1/Microsoft.Authorization/924b5b06-fe70-9ab7-03f4-14671370765e", actual["name"].Value<string>());
            actual = subResources[2] as JObject;
            Assert.Equal("vnet-001/subnet2/Microsoft.Authorization/c7db2a25-b75f-d22b-f692-bbb38c83d9d0", actual["name"].Value<string>());

            actual = resources[7];
            Assert.False(actual["rootDeployment"].Value<bool>());
            Assert.Equal("vnetDelegation", actual["name"].Value<string>());
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
        }

        [Fact]
        public void AdvancedTemplateParsing1()
        {
            var resources = ProcessTemplate(GetSourcePath("Resources.FrontDoor.Template.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(3, resources.Length);
            Assert.Equal("my-frontdoor", resources[2]["properties"]["frontendEndpoints"][0]["name"].Value<string>());
            Assert.Equal("my-frontdoor.azurefd.net", resources[2]["properties"]["frontendEndpoints"][0]["properties"]["hostName"].Value<string>());
        }

        [Fact]
        public void AdvancedTemplateParsing2()
        {
            var resources = ProcessTemplate(GetSourcePath("Resources.Template4.json"), null);
            Assert.NotNull(resources);
        }

        [Fact]
        public void AdvancedTemplateParsing3()
        {
            var resources = ProcessTemplate(GetSourcePath("Template.Parsing.1.json"), null);
            Assert.NotNull(resources);
        }

        [Fact]
        public void AdvancedTemplateParsing4()
        {
            var resources = ProcessTemplate(GetSourcePath("Template.Parsing.2.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(2, resources.Length);

            var actual1 = resources[1];
            Assert.Equal("defaultvalue", actual1["name"].Value<string>());
            Assert.Equal("eastus", actual1["location"].Value<string>());
            Assert.False(actual1["properties"]["enabledForDeployment"].Value<bool>());
            Assert.False(actual1["properties"]["enabledForTemplateDeployment"].Value<bool>());
            Assert.False(actual1["properties"]["enabledForDiskEncryption"].Value<bool>());
            Assert.Equal(2, actual1["properties"]["accessPolicies"].Value<JArray>().Count);
            Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", actual1["properties"]["tenantId"].Value<string>());
            Assert.True(actual1["properties"]["enableSoftDelete"].Value<bool>());
            Assert.True(actual1["properties"]["enablePurgeProtection"].Value<bool>());
        }

        [Fact]
        public void UserDefinedFunctions()
        {
            var resources = ProcessTemplate(GetSourcePath("Template.Parsing.4.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(2, resources.Length);

            var actual1 = resources[1];
            Assert.Equal("Hello world", actual1["properties"]["keyString"].Value<string>());
            Assert.Equal("world", actual1["properties"]["keyObject"]["message"].Value<string>());
            Assert.Equal("Hello world", actual1["properties"]["keyObject"]["value"].Value<string>());
        }

        [Fact]
        public void NestedTemplateParsingInner()
        {
            var resources = ProcessTemplate(GetSourcePath("Template.Parsing.3.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(3, resources.Length);

            var actual = resources[0];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());

            actual = resources[1];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            Assert.Equal("innerDeployment", actual["name"].Value<string>());

            actual = resources[2];
            Assert.Equal("Microsoft.Network/networkWatchers/flowLogs", actual["type"].Value<string>());
            Assert.Equal("NetworkWatcher_eastus/FlowLog1", actual["name"].Value<string>());
            Assert.Equal("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/networkSecurityGroups/nsg-001", actual["properties"]["targetResourceId"].Value<string>());
            Assert.Equal("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Storage/storageAccounts/flowlogs5f3e65afb63bb", actual["properties"]["storageId"].Value<string>());
            Assert.Equal("NetworkWatcherRG", actual["tags"]["resourceGroup"].Value<string>());
        }

        [Fact]
        public void NestedTemplateParsingInner2()
        {
            var resources = ProcessTemplate(GetSourcePath("Template.Parsing.5.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(6, resources.Length);

            Assert.Equal("Microsoft.Resources/deployments", resources[0]["type"].Value<string>());
            Assert.Equal("Microsoft.Resources/deployments", resources[1]["type"].Value<string>());
            Assert.Equal("main", resources[1]["name"].Value<string>());
            Assert.Equal("myVnet/my-subnet", resources[2]["name"].Value<string>());
            Assert.Equal("my-pip1", resources[3]["name"].Value<string>());
            Assert.Equal("my-pip2", resources[4]["name"].Value<string>());
            Assert.Equal("my-nic", resources[5]["name"].Value<string>());
        }

        [Fact]
        public void NestedResources()
        {
            // Key Vault
            var resources = ProcessTemplate(GetSourcePath("Resources.KeyVault.Template.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(2, resources.Length);

            var actual = resources[1];
            Assert.Equal("resources[0]", actual["_PSRule"]["path"]);
            var subResources = actual["resources"].Value<JArray>();
            Assert.Equal(2, subResources.Count);
            Assert.Equal("keyvault1/Microsoft.Insights/service", subResources[0]["name"].Value<string>());
            Assert.Equal("resources[1]", subResources[0]["_PSRule"]["path"]);
            Assert.Equal("monitor", subResources[1]["name"].Value<string>());
            Assert.Equal("resources[2]", subResources[1]["_PSRule"]["path"]);

            // Storage
            resources = ProcessTemplate(GetSourcePath("Resources.Storage.Template.json"), GetSourcePath("Resources.Storage.Parameters.json"));
            Assert.NotNull(resources);
            Assert.Equal(2, resources.Length);

            actual = resources[1];
            Assert.Equal("resources[0]", actual["_PSRule"]["path"]);
            subResources = actual["resources"].Value<JArray>();
            Assert.Equal(3, subResources.Count);
            Assert.Equal("storage1/default", subResources[0]["name"].Value<string>());
            //Assert.Equal("resources[0].resources[0]", subResources[0]["_PSRule"]["path"]);
            Assert.Equal("storage1/default/arm", subResources[1]["name"].Value<string>());
            Assert.Equal("resources[1]", subResources[1]["_PSRule"]["path"]);
            Assert.Equal("storage1/default", subResources[2]["name"].Value<string>());
            Assert.Equal("resources[2]", subResources[2]["_PSRule"]["path"]);
        }

        [Fact]
        public void NestedCopyLoops()
        {
            var resources = ProcessTemplate(GetSourcePath("Template.Parsing.13.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(3, resources.Length);

            Assert.Equal("Microsoft.Resources/deployments", resources[0]["type"].Value<string>());
            Assert.Equal("Microsoft.Authorization/policySetDefinitions", resources[1]["type"].Value<string>());
            Assert.Equal(4, resources[1]["properties"]["policyDefinitions"].Value<JArray>().Count);
            Assert.Equal("Microsoft.Authorization/policySetDefinitions", resources[2]["type"].Value<string>());
            Assert.Single(resources[2]["properties"]["policyDefinitions"].Value<JArray>());
        }

        [Fact]
        public void TryParentResourceId()
        {
            const string expected1 = "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.ServiceBus/namespaces/besubns";
            const string expected2 = "/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.KeyVault/vaults/keyvault1";
            var context = new TemplateContext();

            var actual = JObject.Parse("{ \"type\": \"Microsoft.ServiceBus/namespaces/topics\", \"name\": \"besubns/demo1\" }");
            context.UpdateResourceScope(actual);
            context.TryParentResourceId(actual, out var resourceId);
            Assert.Equal(expected1, resourceId[0]);

            actual = JObject.Parse("{ \"type\": \"Microsoft.KeyVault/vaults\", \"name\": \"keyvault1\" }");
            context.UpdateResourceScope(actual);
            context.TryParentResourceId(actual, out resourceId);
            Assert.Null(resourceId);

            actual = JObject.Parse("{ \"type\": \"Microsoft.KeyVault/vaults/providers/diagnosticsettings\", \"name\": \"keyvault1/Microsoft.Insights/service\" }");
            context.UpdateResourceScope(actual);
            context.TryParentResourceId(actual, out resourceId);
            Assert.Equal(expected2, resourceId[0]);

            actual = JObject.Parse("{ \"type\": \"Microsoft.Insights/diagnosticsettings\", \"name\": \"auditing-storage\", \"scope\": \"Microsoft.KeyVault/vaults/keyvault1\" }");
            context.UpdateResourceScope(actual);
            context.TryParentResourceId(actual, out resourceId);
            Assert.Equal(expected2, resourceId[0]);
        }

        [Fact]
        public void ResourcesWithSource()
        {
            var resources = ProcessTemplate(GetSourcePath("Resources.Template.json"), GetSourcePath("Resources.Parameters.json"));
            Assert.NotNull(resources);
            Assert.Equal(8, resources.Length);

            var actual = resources[0];
            Assert.EndsWith("Resources.Template.json", actual["_PSRule"]["source"][0]["file"].Value<string>());
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());

            actual = resources[1];
            Assert.EndsWith("Resources.Template.json", actual["_PSRule"]["source"][0]["file"].Value<string>());
            Assert.Equal("route-subnet1", actual["name"].Value<string>());
            Assert.Equal("Microsoft.Network/routeTables", actual["type"].Value<string>());

            actual = resources[2];
            Assert.EndsWith("Resources.Template.json", actual["_PSRule"]["source"][0]["file"].Value<string>());
            Assert.Equal("route-subnet2", actual["name"].Value<string>());
            Assert.Equal("Microsoft.Network/routeTables", actual["type"].Value<string>());

            actual = resources[3];
            Assert.EndsWith("Resources.Template.json", actual["_PSRule"]["source"][0]["file"].Value<string>());
            Assert.Equal("nsg-subnet1", actual["name"].Value<string>());
            Assert.Equal("Microsoft.Network/networkSecurityGroups", actual["type"].Value<string>());

            actual = resources[4];
            Assert.EndsWith("Resources.Template.json", actual["_PSRule"]["source"][0]["file"].Value<string>());
            Assert.Equal("nsg-subnet2", actual["name"].Value<string>());
            Assert.Equal("Microsoft.Network/networkSecurityGroups", actual["type"].Value<string>());

            actual = resources[5];
            Assert.EndsWith("Resources.Template.json", actual["_PSRule"]["source"][0]["file"].Value<string>());
            Assert.Equal("nsg-extra", actual["name"].Value<string>());
            Assert.Equal("Microsoft.Network/networkSecurityGroups", actual["type"].Value<string>());

            actual = resources[6];
            Assert.EndsWith("Resources.Template.json", actual["_PSRule"]["source"][0]["file"].Value<string>());
            Assert.Equal("vnet-001", actual["name"].Value<string>());
            Assert.Equal("Microsoft.Network/virtualNetworks", actual["type"].Value<string>());

            actual = resources[7];
            Assert.EndsWith("Resources.Template.json", actual["_PSRule"]["source"][0]["file"].Value<string>());
            Assert.Equal("vnetDelegation", actual["name"].Value<string>());
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
        }

        [Fact]
        public void BooleanStringProperty()
        {
            var resources = ProcessTemplate(GetSourcePath("Template.Parsing.6.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(2, resources.Length);

            var actual1 = resources[1];
            Assert.Equal("True", actual1["properties"]["value1"].Value<string>());
            Assert.Equal("true", actual1["properties"]["value2"].Value<string>());
            Assert.Equal("false", actual1["properties"]["value3"].Value<string>());
            Assert.Equal("Other", actual1["properties"]["value4"].Value<string>());
        }

        [Fact]
        public void NestedDeploymentWithMock()
        {
            var resources = ProcessTemplate(GetSourcePath("Template.Parsing.7.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(3, resources.Length);

            var actual = resources[0];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            Assert.Equal("", actual["_PSRule"]["path"]);

            actual = resources[1];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            Assert.Equal("addRoleAssignment", actual["name"].Value<string>());
            Assert.Equal("resources[0]", actual["_PSRule"]["path"].ToString());

            actual = resources[2];
            Assert.Equal("Microsoft.Authorization/roleAssignments", actual["type"].Value<string>());
            Assert.Equal("resources[0].properties.template.resources[0]", actual["_PSRule"]["path"].ToString());
        }

        [Fact]
        public void DeploymentWithOptions()
        {
            var resources = ProcessTemplate(GetSourcePath("Template.Parsing.8.json"), null, PSRuleOption.FromFileOrDefault(GetSourcePath("ps-rule-options.yaml")));
            Assert.NotNull(resources);
            Assert.Equal(2, resources.Length);

            var actual1 = resources[1];
            Assert.Equal("Microsoft.Network/networkWatchers/flowLogs", actual1["type"].Value<string>());
            Assert.Equal("prod", actual1["tags"]["Environment"].Value<string>());
            Assert.Equal("PROD", actual1["tags"]["EnvUpper"].Value<string>());
            Assert.Equal("11111111-1111-1111-1111-111111111111", actual1["tags"]["TenantId"].Value<string>());
            Assert.Equal("Unit Test Tenant", actual1["tags"]["TenantDisplayName"].Value<string>());

            var zones = actual1["tags"]["PickZones"].Values<string>().ToArray();
            Assert.Equal(3, zones.Length);
            Assert.Equal("1", zones[0]);
            Assert.Equal("2", zones[1]);
            Assert.Equal("3", zones[2]);
        }

        [Fact]
        public void StrongTypeParameter()
        {
            var resources = ProcessTemplate(GetSourcePath("Template.StrongType.1.json"), GetSourcePath("Template.StrongType.1.Parameters.json"));
            Assert.NotNull(resources);
            Assert.Equal(2, resources.Length);

            var actual1 = resources[0];
            Assert.Equal("Microsoft.Resources/deployments", actual1["type"].Value<string>());
            Assert.Single(actual1["_PSRule"]["issue"].Value<JArray>());
            Assert.Equal("PSRule.Rules.Azure.Template.ParameterStrongType", actual1["_PSRule"]["issue"][0]["type"].Value<string>());
            Assert.Equal("location", actual1["_PSRule"]["issue"][0]["name"].Value<string>());

            resources = ProcessTemplate(GetSourcePath("Template.StrongType.1.json"), GetSourcePath("Template.StrongType.2.Parameters.json"));
            Assert.NotNull(resources);
            Assert.Equal(2, resources.Length);

            var actual2 = resources[0];
            Assert.Equal("Microsoft.Resources/deployments", actual2["type"].Value<string>());
            Assert.Single(actual2["_PSRule"]["issue"].Value<JArray>());
            Assert.Equal("PSRule.Rules.Azure.Template.ParameterStrongType", actual2["_PSRule"]["issue"][0]["type"].Value<string>());
            Assert.Equal("workspaceId", actual2["_PSRule"]["issue"][0]["name"].Value<string>());

            resources = ProcessTemplate(GetSourcePath("Template.StrongType.1.json"), GetSourcePath("Template.StrongType.3.Parameters.json"));
            Assert.NotNull(resources);
            Assert.Equal(2, resources.Length);

            var actual3 = resources[0];
            Assert.Equal("Microsoft.Resources/deployments", actual3["type"].Value<string>());
            Assert.False(actual3["_PSRule"].Value<JObject>().ContainsKey("issue"));
        }

        [Fact]
        public void StrongTypeNestedParameter()
        {
            var resources = ProcessTemplate(GetSourcePath("Template.Bicep.2.json"), null, PSRuleOption.FromFileOrDefault(GetSourcePath("ps-rule-options.yaml")));
            Assert.NotNull(resources);
            Assert.Equal(7, resources.Length);

            var actual = resources[1];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            Assert.Single(actual["_PSRule"]["issue"].Value<JArray>());
            Assert.Equal("PSRule.Rules.Azure.Template.ParameterStrongType", actual["_PSRule"]["issue"][0]["type"].Value<string>());
            Assert.Equal("location", actual["_PSRule"]["issue"][0]["name"].Value<string>());

            actual = resources[3];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            Assert.Single(actual["_PSRule"]["issue"].Value<JArray>());
            Assert.Equal("PSRule.Rules.Azure.Template.ParameterStrongType", actual["_PSRule"]["issue"][0]["type"].Value<string>());
            Assert.Equal("workspaceId", actual["_PSRule"]["issue"][0]["name"].Value<string>());

            actual = resources[5];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            Assert.False(actual["_PSRule"].Value<JObject>().ContainsKey("issue"));
        }

        [Fact]
        public void ExpressionLength()
        {
            var resources = ProcessTemplate(GetSourcePath("Template.Parsing.9.json"), GetSourcePath("Template.Parsing.9.Parameters.json"));
            Assert.NotNull(resources);
            Assert.Equal(2, resources.Length);

            var actual1 = resources[0];
            Assert.Equal("Microsoft.Resources/deployments", actual1["type"].Value<string>());
            Assert.Equal("PSRule.Rules.Azure.Template.ExpressionLength", actual1["_PSRule"]["issue"][0]["type"].Value<string>());

            resources = ProcessTemplate(GetSourcePath("Template.Parsing.2.json"), GetSourcePath("Template.Parsing.2.Parameters.json"));
            Assert.NotNull(resources);
            Assert.Equal(2, resources.Length);

            var actual2 = resources[0];
            Assert.Equal("Microsoft.Resources/deployments", actual2["type"].Value<string>());
            Assert.False(actual2["_PSRule"].Value<JObject>().ContainsKey("issue"));

            resources = ProcessTemplate(GetSourcePath("Template.Parsing.10.json"), GetSourcePath("Template.Parsing.10.Parameters.json"));
            Assert.NotNull(resources);
            Assert.Equal(2, resources.Length);

            var actual3 = resources[0];
            Assert.Equal("Microsoft.Resources/deployments", actual3["type"].Value<string>());
            Assert.False(actual3["_PSRule"].Value<JObject>().ContainsKey("issue"));
        }

        [Fact]
        public void EqualsEmptyObject()
        {
            var resources = ProcessTemplate(GetSourcePath("Template.Parsing.11.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(6, resources.Length);

            var actual = resources[0];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());

            actual = resources[1];
            Assert.Equal("Namespace/resourceType", actual["type"].Value<string>());
            Assert.Equal(JTokenType.Null, actual["properties"]["settings"].Type);

            actual = resources[2];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            Assert.Equal("deploy1", actual["name"].Value<string>());

            actual = resources[3];
            Assert.Equal("Namespace/resourceTypeN", actual["type"].Value<string>());
            Assert.Equal("item1", actual["name"].Value<string>());
            Assert.Equal(1, actual["properties"]["priority"].Value<int>());
            Assert.Equal("rule1", actual["properties"]["rules"][0]["name"].Value<string>());
            Assert.Equal("rule2", actual["properties"]["rules"][1]["name"].Value<string>());

            actual = resources[4];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            Assert.Equal("deploy2", actual["name"].Value<string>());

            actual = resources[5];
            Assert.Equal("Namespace/resourceTypeN", actual["type"].Value<string>());
            Assert.Equal("item2", actual["name"].Value<string>());
            Assert.Equal(1, actual["properties"]["priority"].Value<int>());
            Assert.Equal("rule3", actual["properties"]["rules"][0]["name"].Value<string>());
            Assert.Equal("rule4", actual["properties"]["rules"][1]["name"].Value<string>());
        }

        [Fact]
        public void WithParameterDefaults()
        {
            var resources = ProcessTemplate(GetSourcePath("Template.Parsing.10.json"), null, PSRuleOption.FromFileOrDefault(GetSourcePath("ps-rule-options.yaml")));
            Assert.NotNull(resources);
            Assert.Equal(2, resources.Length);

            Assert.Equal("aks-resource123", resources[1]["name"].Value<string>());
            Assert.Equal("dev", resources[1]["tags"]["env"].Value<string>());
            Assert.Equal("value", resources[1]["tags"]["test"].Value<string>());
        }

        [Fact]
        public void WithDependantParameters()
        {
            var resources = ProcessTemplate(GetSourcePath("Template.Parsing.12.json"), null);
            Assert.NotNull(resources);
        }

        [Fact]
        public void WithOutputs()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.2.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(10, resources.Length);

            var actual = resources[0];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());

            actual = resources[1];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            Assert.Equal("storage1", actual["name"].Value<string>());

            actual = resources[2];
            Assert.Equal("Microsoft.Storage/storageAccounts", actual["type"].Value<string>());
            Assert.Equal("sabicep001", actual["name"].Value<string>());
            Assert.Equal("test", actual["tags"]["env"].Value<string>());

            actual = resources[3];
            Assert.Equal("Microsoft.Network/privateEndpoints", actual["type"].Value<string>());
            Assert.Equal("pe-sabicep001", actual["name"].Value<string>());

            actual = resources[4];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            Assert.Equal("storage3", actual["name"].Value<string>());

            actual = resources[5];
            Assert.Equal("Microsoft.Storage/storageAccounts", actual["type"].Value<string>());
            Assert.Equal("sabicep001f8cbd7940fe93", actual["name"].Value<string>());
            Assert.Equal("test", actual["tags"]["env"].Value<string>());

            actual = resources[6];
            Assert.Equal("Microsoft.Network/privateEndpoints", actual["type"].Value<string>());
            Assert.Equal("pe-sabicep001f8cbd7940fe93", actual["name"].Value<string>());

            actual = resources[7];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            Assert.Equal("storage2", actual["name"].Value<string>());

            actual = resources[8];
            Assert.Equal("Microsoft.Storage/storageAccounts", actual["type"].Value<string>());
            Assert.Equal("sabicep002", actual["name"].Value<string>());
            Assert.Equal("test", actual["tags"]["env"].Value<string>());

            actual = resources[9];
            Assert.Equal("Microsoft.Network/privateEndpoints", actual["type"].Value<string>());
            Assert.Equal("pe-sabicep002", actual["name"].Value<string>());
        }

        [Fact]
        public void WithOutputsWithSplit()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.3.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(7, resources.Length);

            var actual = resources[0];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());

            actual = resources[1];
            Assert.Equal("Microsoft.Storage/storageAccounts", actual["type"].Value<string>());
            Assert.Equal("storage1", actual["name"].Value<string>());

            actual = resources[2];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            Assert.Equal("blob_deploy", actual["name"].Value<string>());

            actual = resources[3];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            Assert.Equal("pe_deploy", actual["name"].Value<string>());

            actual = resources[4];
            Assert.Equal("Microsoft.Network/privateEndpoints", actual["type"].Value<string>());
            Assert.Equal("pe-storage1", actual["name"].Value<string>());

            actual = resources[5];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            Assert.Equal("pe_dns_deploy", actual["name"].Value<string>());

            actual = resources[6];
            Assert.Equal("Microsoft.Network/privateDnsZones/A", actual["type"].Value<string>());
            Assert.Equal("privatelink.blob.core.windows.net/storage1", actual["name"].Value<string>());
        }

        [Fact]
        public void WithOutputsWithoutProperties()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.4.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(6, resources.Length);

            var actual = resources[0];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());

            actual = resources[1];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            Assert.Equal("mi", actual["name"].Value<string>());

            actual = resources[2];
            Assert.Equal("Microsoft.ManagedIdentity/userAssignedIdentities", actual["type"].Value<string>());
            Assert.Equal("mi", actual["name"].Value<string>());

            actual = resources[3];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            Assert.Equal("kv", actual["name"].Value<string>());

            actual = resources[4];
            var subResources = actual["resources"].Value<JArray>();
            Assert.Equal("Microsoft.KeyVault/vaults", actual["type"].Value<string>());
            Assert.Equal("keyvault001", actual["name"].Value<string>());
            Assert.Single(subResources);
            Assert.Equal("service", subResources[0]["name"].Value<string>());

            actual = resources[5];
            Assert.Equal("Microsoft.Authorization/roleAssignments", actual["type"].Value<string>());
            Assert.Equal("af653e5f-3bb6-d1bd-fa61-e314ddbfb39c", actual["name"].Value<string>());
        }

        [Fact]
        public void WithArrayFromRuntimeProperty()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.5.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(8, resources.Length);
        }

        [Fact]
        public void SecretOutputs()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.7.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(6, resources.Length);

            var actual = resources[0];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            var issues = actual["_PSRule"]["issue"].Value<JArray>();
            Assert.Equal(3, issues.Count);
            Assert.Equal("PSRule.Rules.Azure.Template.OutputSecretValue", issues[0]["type"].Value<string>());
            Assert.Equal("secret", issues[0]["name"].Value<string>());
            Assert.Equal("PSRule.Rules.Azure.Template.OutputSecretValue", issues[1]["type"].Value<string>());
            Assert.Equal("secretFromListKeys", issues[1]["name"].Value<string>());
            Assert.Equal("PSRule.Rules.Azure.Template.OutputSecretValue", issues[2]["type"].Value<string>());
            Assert.Equal("secretFromChild", issues[2]["name"].Value<string>());

            actual = resources[3];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
            issues = actual["_PSRule"]["issue"].Value<JArray>();
            Assert.Single(issues);
            Assert.Equal("PSRule.Rules.Azure.Template.OutputSecretValue", issues[0]["type"].Value<string>());
            Assert.Equal("secretFromParameter", issues[0]["name"].Value<string>());
        }

        [Fact]
        public void OutputCopy()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.5.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(8, resources.Length);

            var actual = resources[0];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());
        }

        [Fact]
        public void MaterializedView()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.8.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(8, resources.Length);

            var storage = resources.FirstOrDefault(r => r["type"].ToString() == "Microsoft.Storage/storageAccounts");
            Assert.NotNull(storage);
            Assert.Equal("Standard_LRS", storage["sku"]["name"].ToString());
            Assert.Equal("TLS1_0", storage["properties"]["minimumTlsVersion"].ToString());
            Assert.True(storage["properties"]["allowBlobPublicAccess"].Value<bool>());
            var subResources = storage["resources"].Values<JObject>().ToArray();
            Assert.Single(subResources);
            Assert.False(subResources[0]["properties"]["deleteRetentionPolicy"]["enabled"].Value<bool>());

            var web = resources.FirstOrDefault(r => r["type"].ToString() == "Microsoft.Web/sites");
            Assert.Equal("1.0", web["properties"]["siteConfig"]["minTlsVersion"].ToString());

            var sqlServer = resources.FirstOrDefault(r => r["type"].ToString() == "Microsoft.Sql/servers");
            Assert.Equal("abc", sqlServer["properties"]["administrators"]["login"].ToString());
            Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", sqlServer["identity"]["principalId"]);
            Assert.Equal("ffffffff-ffff-ffff-ffff-ffffffffffff", sqlServer["identity"]["tenantId"]);
        }

        [Fact]
        public void ParameterFunctionVariable()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.10.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(3, resources.Length);
        }

        [Fact]
        public void NestedParameterValueLoops()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.11.json"), null);
            Assert.NotNull(resources);
        }

        [Fact]
        public void SplitLastRuntimeProperties()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.12.json"), null);
            Assert.NotNull(resources);
        }

        [Fact]
        public void LambdaFunctions()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.13.json"), null, out var templateContext);
            Assert.NotNull(resources);

            // Filter
            Assert.True(templateContext.RootDeployment.TryOutput("oldDogs", out JObject oldDogs));
            Assert.Equal(2, oldDogs["value"].Value<JArray>().Count);
            Assert.Equal("Evie", oldDogs["value"][0]["name"].Value<string>());
            Assert.Equal("Kira", oldDogs["value"][1]["name"].Value<string>());

            // Map
            Assert.True(templateContext.RootDeployment.TryOutput("dogNames", out JObject dogNames));
            Assert.Equal(4, dogNames["value"].Value<JArray>().Count);
            Assert.Equal("Evie", dogNames["value"][0].Value<string>());
            Assert.Equal("Casper", dogNames["value"][1].Value<string>());
            Assert.Equal("Indy", dogNames["value"][2].Value<string>());
            Assert.Equal("Kira", dogNames["value"][3].Value<string>());

            Assert.True(templateContext.RootDeployment.TryOutput("sayHi", out JObject sayHi));
            Assert.Equal(4, sayHi["value"].Value<JArray>().Count);
            Assert.Equal("Hello Evie!", sayHi["value"][0].Value<string>());
            Assert.Equal("Hello Casper!", sayHi["value"][1].Value<string>());
            Assert.Equal("Hello Indy!", sayHi["value"][2].Value<string>());
            Assert.Equal("Hello Kira!", sayHi["value"][3].Value<string>());

            Assert.True(templateContext.RootDeployment.TryOutput("mapObject", out JObject mapObject));
            Assert.Equal(4, mapObject["value"].Value<JArray>().Count);
            Assert.Equal(0, mapObject["value"][0]["i"].Value<int>());
            Assert.Equal("Evie", mapObject["value"][0]["dog"].Value<string>());
            Assert.Equal("Ahoy, Evie!", mapObject["value"][0]["greeting"].Value<string>());
            Assert.Equal(1, mapObject["value"][1]["i"].Value<int>());
            Assert.Equal("Casper", mapObject["value"][1]["dog"].Value<string>());
            Assert.Equal("Ahoy, Casper!", mapObject["value"][1]["greeting"].Value<string>());
            Assert.Equal(2, mapObject["value"][2]["i"].Value<int>());
            Assert.Equal("Indy", mapObject["value"][2]["dog"].Value<string>());
            Assert.Equal("Ahoy, Indy!", mapObject["value"][2]["greeting"].Value<string>());
            Assert.Equal(3, mapObject["value"][3]["i"].Value<int>());
            Assert.Equal("Kira", mapObject["value"][3]["dog"].Value<string>());
            Assert.Equal("Ahoy, Kira!", mapObject["value"][3]["greeting"].Value<string>());

            // Reduce
            Assert.True(templateContext.RootDeployment.TryOutput("totalAge", out JObject totalAge));
            Assert.Equal(18, totalAge["value"].Value<int>());
            Assert.True(templateContext.RootDeployment.TryOutput("totalAgeAdd1", out JObject totalAgeAdd1));
            Assert.Equal(19, totalAgeAdd1["value"].Value<int>());

            // Sort
            Assert.True(templateContext.RootDeployment.TryOutput("dogsByAge", out JObject dogsByAge));
            Assert.Equal(4, dogsByAge["value"].Value<JArray>().Count);
            Assert.Equal("Kira", dogsByAge["value"][0]["name"].Value<string>());
            Assert.Equal("Evie", dogsByAge["value"][1]["name"].Value<string>());
            Assert.Equal("Casper", dogsByAge["value"][2]["name"].Value<string>());
            Assert.Equal("Indy", dogsByAge["value"][3]["name"].Value<string>());

            // ToObject
            Assert.True(templateContext.RootDeployment.TryOutput("objectMap", out JObject objectMap));
            Assert.Equal(123, objectMap["value"]["1"].Value<int>());
            Assert.Equal(456, objectMap["value"]["4"].Value<int>());
            Assert.Equal(789, objectMap["value"]["7"].Value<int>());
            Assert.True(templateContext.RootDeployment.TryOutput("objectMap2", out JObject objectMap2));
            Assert.True(objectMap2["value"]["0"]["isEven"].Value<bool>());
            Assert.False(objectMap2["value"]["0"]["isGreaterThan2"].Value<bool>());
            Assert.False(objectMap2["value"]["1"]["isEven"].Value<bool>());
            Assert.False(objectMap2["value"]["1"]["isGreaterThan2"].Value<bool>());
            Assert.True(objectMap2["value"]["2"]["isEven"].Value<bool>());
            Assert.False(objectMap2["value"]["2"]["isGreaterThan2"].Value<bool>());
            Assert.False(objectMap2["value"]["3"]["isEven"].Value<bool>());
            Assert.True(objectMap2["value"]["3"]["isGreaterThan2"].Value<bool>());
            Assert.True(templateContext.RootDeployment.TryOutput("objectMapNull", out JObject objectMapNull));
            Assert.True(objectMapNull["value"][""].Type == JTokenType.Null);
            Assert.Equal(123, objectMapNull["value"]["123"].Value<int>());
            Assert.Equal(456, objectMapNull["value"]["456"].Value<int>());
            Assert.Equal(789, objectMapNull["value"]["789"].Value<int>());
        }

        [Fact]
        public void CustomTypes()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.14.json"), null);
            Assert.NotNull(resources);
        }

        [Fact]
        public void ObjectToNull()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.15.json"), null, out _);
            Assert.NotNull(resources);
        }

        [Fact]
        public void BatchSize()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.16.json"), null, out _);
            Assert.NotNull(resources);
            Assert.Equal(3, resources.Length);

            var actual = resources[0];
            Assert.Equal("Microsoft.Resources/deployments", actual["type"].Value<string>());

            actual = resources[1];
            Assert.Equal("Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments", actual["type"].Value<string>());
            Assert.Equal("cosmos-repro/a", actual["name"].Value<string>());

            actual = resources[2];
            Assert.Equal("Microsoft.DocumentDB/databaseAccounts/sqlRoleAssignments", actual["type"].Value<string>());
            Assert.Equal("cosmos-repro/b", actual["name"].Value<string>());
        }

        [Fact]
        public void DependsOnCrossScope()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.17.json"), null, out _);
            Assert.NotNull(resources);
            Assert.Equal(6, resources.Length);
        }

        [Fact]
        public void OrLeftHandEvaluation()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.19.json"), null, out _);
            Assert.Equal(2, resources.Length);
        }

        [Fact]
        public void InterdependentVariableCopyLoop()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.20.json"), null, out _);
            Assert.Equal(2, resources.Length);
        }

        [Fact]
        public void FilterBug()
        {
            var resources = ProcessTemplate(GetSourcePath("Tests.Bicep.21.json"), null, out _);
            Assert.Equal(2, resources.Length);
        }

        #region Helper methods

        private static string GetSourcePath(string fileName)
        {
            return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, fileName);
        }

        private static JObject[] ProcessTemplate(string templateFile, string parametersFile)
        {
            var context = new PipelineContext(PSRuleOption.Default, null);
            var helper = new TemplateHelper(context);
            helper.ProcessTemplate(templateFile, parametersFile, out var templateContext);
            return templateContext.GetResources().Select(i => i.Value).ToArray();
        }

        private static JObject[] ProcessTemplate(string templateFile, string parametersFile, out TemplateContext templateContext)
        {
            var context = new PipelineContext(PSRuleOption.Default, null);
            var helper = new TemplateHelper(context);
            helper.ProcessTemplate(templateFile, parametersFile, out templateContext);
            return templateContext.GetResources().Select(i => i.Value).ToArray();
        }

        private static JObject[] ProcessTemplate(string templateFile, string parametersFile, PSRuleOption option)
        {
            var context = new PipelineContext(option, null);
            var helper = new TemplateHelper(context);
            helper.ProcessTemplate(templateFile, parametersFile, out var templateContext);
            return templateContext.GetResources().Select(i => i.Value).ToArray();
        }

        #endregion Helper methods
    }
}
