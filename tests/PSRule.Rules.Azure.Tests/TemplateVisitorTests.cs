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
            Assert.Equal(10, resources.Length);

            var actual1 = resources[1];
            Assert.Equal("vnet-001", actual1["name"].Value<string>());
            Assert.Equal("10.1.0.0/24", actual1["properties"]["addressSpace"]["addressPrefixes"][0].Value<string>());
            Assert.Equal(3, actual1["properties"]["subnets"].Value<JArray>().Count);
            Assert.Equal("10.1.0.32/28", actual1["properties"]["subnets"][1]["properties"]["addressPrefix"].Value<string>());
            Assert.Equal("Networking", actual1["tags"]["role"].Value<string>());
            Assert.Equal("region-A", actual1["location"].Value<string>());

            var actual2 = resources[2];
            Assert.Equal("vnet-001/subnet2", actual2["name"].Value<string>());
            Assert.Equal("vnetDelegation", actual2["properties"]["delegations"][0]["name"].Value<string>());

            var actual3 = resources[3];
            Assert.Equal("vnet-001/subnet1/Microsoft.Authorization/924b5b06-fe70-9ab7-03f4-14671370765e", actual3["name"].Value<string>());
        }

        [Fact]
        public void AdvancedTemplateParsing1()
        {
            var resources = ProcessTemplate(GetSourcePath("Resources.FrontDoor.Template.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(3, resources.Length);
            Assert.Equal("my-frontdoor", resources[1]["properties"]["frontendEndpoints"][0]["name"].Value<string>());
            Assert.Equal("my-frontdoor.azurefd.net", resources[1]["properties"]["frontendEndpoints"][0]["properties"]["hostName"].Value<string>());
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
            Assert.Equal(2, resources.Length);

            var actual1 = resources[1];
            Assert.Equal("Microsoft.Network/networkWatchers/flowLogs", actual1["type"].Value<string>());
            Assert.Equal("NetworkWatcher_eastus/FlowLog1", actual1["name"].Value<string>());
            Assert.Equal("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/networkSecurityGroups/nsg-001", actual1["properties"]["targetResourceId"].Value<string>());
            Assert.Equal("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Storage/storageAccounts/flowlogs5f3e65afb63bb", actual1["properties"]["storageId"].Value<string>());
            Assert.Equal("NetworkWatcherRG", actual1["tags"]["resourceGroup"].Value<string>());
        }

        [Fact]
        public void NestedTemplateParsingInner2()
        {
            var resources = ProcessTemplate(GetSourcePath("Template.Parsing.5.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(5, resources.Length);

            Assert.Equal("myVnet/my-subnet", resources[1]["name"].Value<string>());
            Assert.Equal("my-pip1", resources[2]["name"].Value<string>());
            Assert.Equal("my-pip2", resources[3]["name"].Value<string>());
            Assert.Equal("my-nic", resources[4]["name"].Value<string>());
        }

        [Fact]
        public void NestedResources()
        {
            var resources = ProcessTemplate(GetSourcePath("Resources.KeyVault.Template.json"), null);
            Assert.NotNull(resources);
            Assert.Equal(2, resources.Length);

            var actual1 = resources[1];
            var subResources = actual1["resources"].Value<JArray>();
            Assert.Equal(2, subResources.Count);
            Assert.Equal("keyvault1/Microsoft.Insights/service", subResources[0]["name"].Value<string>());
            Assert.Equal("monitor", subResources[1]["name"].Value<string>());
        }

        [Fact]
        public void TryParentResourceId()
        {
            const string expected1 = "Microsoft.ServiceBus/namespaces/besubns";
            const string expected2 = "Microsoft.KeyVault/vaults/keyvault1";

            var actual = JObject.Parse("{ \"type\": \"Microsoft.ServiceBus/namespaces/topics\", \"name\": \"besubns/demo1\" }");
            TemplateContext.TryParentResourceId(actual, out string[] resourceId);
            Assert.Equal(expected1, resourceId[0]);

            actual = JObject.Parse("{ \"type\": \"Microsoft.KeyVault/vaults\", \"name\": \"keyvault1\" }");
            TemplateContext.TryParentResourceId(actual, out resourceId);
            Assert.Empty(resourceId);

            actual = JObject.Parse("{ \"type\": \"Microsoft.KeyVault/vaults/providers/diagnosticsettings\", \"name\": \"keyvault1/Microsoft.Insights/service\" }");
            TemplateContext.TryParentResourceId(actual, out resourceId);
            Assert.Equal(expected2, resourceId[0]);

            actual = JObject.Parse("{ \"type\": \"Microsoft.Insights/diagnosticsettings\", \"name\": \"auditing-storage\", \"scope\": \"Microsoft.KeyVault/vaults/keyvault1\" }");
            TemplateContext.TryParentResourceId(actual, out resourceId);
            Assert.Equal(expected2, resourceId[0]);
        }

        [Fact]
        public void ResourcesWithSource()
        {
            var resources = ProcessTemplate(GetSourcePath("Resources.Template.json"), GetSourcePath("Resources.Parameters.json"));
            Assert.NotNull(resources);
            Assert.Equal(10, resources.Length);

            var actual1 = resources[1];
            Assert.EndsWith("Resources.Template.json", actual1["_PSRule"]["source"][0]["file"].Value<string>());
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
            Assert.Equal(2, resources.Length);

            var actual1 = resources[1];
            Assert.Equal("Microsoft.Authorization/roleAssignments", actual1["type"].Value<string>());
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
            Assert.Equal(4, resources.Length);

            var actual = resources[1];
            Assert.Equal("Namespace/resourceType", actual["type"].Value<string>());
            Assert.Equal(JTokenType.Null, actual["properties"]["settings"].Type);

            actual = resources[2];
            Assert.Equal("Namespace/resourceTypeN", actual["type"].Value<string>());
            Assert.Equal("item1", actual["name"].Value<string>());
            Assert.Equal(1, actual["properties"]["priority"].Value<int>());
            Assert.Equal("rule1", actual["properties"]["rules"][0]["name"].Value<string>());
            Assert.Equal("rule2", actual["properties"]["rules"][1]["name"].Value<string>());

            actual = resources[3];
            Assert.Equal("Namespace/resourceTypeN", actual["type"].Value<string>());
            Assert.Equal("item2", actual["name"].Value<string>());
            Assert.Equal(1, actual["properties"]["priority"].Value<int>());
            Assert.Equal("rule3", actual["properties"]["rules"][0]["name"].Value<string>());
            Assert.Equal("rule4", actual["properties"]["rules"][1]["name"].Value<string>());
        }

        #region Helper methods

        private static string GetSourcePath(string fileName)
        {
            return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, fileName);
        }

        private static JObject[] ProcessTemplate(string templateFile, string parametersFile)
        {
            var context = new PipelineContext(PSRuleOption.Default, null);
            var helper = new TemplateHelper(context, "deployment", PSRuleOption.Default.Configuration.ResourceGroup, PSRuleOption.Default.Configuration.Subscription);
            helper.ProcessTemplate(templateFile, parametersFile, out TemplateContext templateContext);
            return templateContext.GetResources().Select(i => i.Value).ToArray();
        }

        private static JObject[] ProcessTemplate(string templateFile, string parametersFile, PSRuleOption option)
        {
            var context = new PipelineContext(option, null);
            var helper = new TemplateHelper(context, "deployment", option.Configuration.ResourceGroup, option.Configuration.Subscription);
            helper.ProcessTemplate(templateFile, parametersFile, out TemplateContext templateContext);
            return templateContext.GetResources().Select(i => i.Value).ToArray();
        }

        #endregion Helper methods
    }
}
