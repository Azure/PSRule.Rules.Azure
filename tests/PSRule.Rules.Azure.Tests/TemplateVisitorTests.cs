// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Template;
using System;
using System.Collections.Generic;
using System.IO;
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
            Assert.Equal(9, resources.Length);

            var actual1 = resources[0];
            Assert.Equal("vnet-001", actual1["name"].Value<string>());
            Assert.Equal("10.1.0.0/24", actual1["properties"]["addressSpace"]["addressPrefixes"][0].Value<string>());
            Assert.Equal(3, actual1["properties"]["subnets"].Value<JArray>().Count);
            Assert.Equal("10.1.0.32/28", actual1["properties"]["subnets"][1]["properties"]["addressPrefix"].Value<string>());
            Assert.Equal("Networking", actual1["tags"]["role"].Value<string>());
            Assert.Equal("region-A", actual1["location"].Value<string>());

            var actual2 = resources[1];
            Assert.Equal("vnet-001/subnet2", actual2["name"].Value<string>());
            Assert.Equal("vnetDelegation", actual2["properties"]["delegations"][0]["name"].Value<string>());

            var actual3 = resources[2];
            Assert.Equal("vnet-001/subnet1/Microsoft.Authorization/924b5b06-fe70-9ab7-03f4-14671370765e", actual3["name"].Value<string>());
        }

        [Fact]
        public void AdvancedTemplateParsing1()
        {
            var resources = ProcessTemplate(GetSourcePath("Resources.FrontDoor.Template.json"), null);
            Assert.NotNull(resources);
            Assert.Equal("my-frontdoor", resources[0]["properties"]["frontendEndpoints"][0]["name"].Value<string>());
            Assert.Equal("my-frontdoor.azurefd.net", resources[0]["properties"]["frontendEndpoints"][0]["properties"]["hostName"].Value<string>());
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
            Assert.Single(resources);

            var actual1 = resources[0];
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
        public void AdvancedTemplateParsing5()
        {
            var resources = ProcessTemplate(GetSourcePath("Template.Parsing.3.json"), null);
            Assert.NotNull(resources);
            Assert.Single(resources);

            var actual1 = resources[0];
            Assert.Equal("Microsoft.Network/networkWatchers/flowLogs", actual1["type"].Value<string>());
            Assert.Equal("NetworkWatcher_eastus/FlowLog1", actual1["name"].Value<string>());
            Assert.Equal("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Network/networkSecurityGroups/nsg-001", actual1["properties"]["targetResourceId"].Value<string>());
            Assert.Equal("/subscriptions/ffffffff-ffff-ffff-ffff-ffffffffffff/resourceGroups/ps-rule-test-rg/providers/Microsoft.Storage/storageAccounts/flowlogs5f3e65afb63bb", actual1["properties"]["storageId"].Value<string>());
            Assert.Equal("NetworkWatcherRG", actual1["tags"]["resourceGroup"].Value<string>());
        }

        private static string GetSourcePath(string fileName)
        {
            return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, fileName);
        }

        private static JObject[] ProcessTemplate(string templateFile, string parametersFile)
        {
            var templateObject = ReadFile<JObject>(templateFile);
            var parametersObject = ReadFile<JObject>(parametersFile);
            var visitor = new TestTemplateVisitor();
            var context = new TemplateContext();
            context.Load(parametersObject);
            visitor.Visit(context, "deployment", templateObject);
            return visitor.TestResources.ToArray();
        }

        private static T ReadFile<T>(string path)
        {
            if (string.IsNullOrEmpty(path) || !File.Exists(path))
                return default(T);

            return JsonConvert.DeserializeObject<T>(File.ReadAllText(path));
        }
    }

    internal sealed class TestSubnet
    {
        internal TestSubnet(string n, string[] r)
        {
            name = n;
            route = r;
        }

        public string name { get; private set; }

        public string[] route { get; private set; }
    }

    internal sealed class TestTemplateVisitor : TemplateVisitor
    {
        internal TestTemplateVisitor()
        {
            TestResources = new List<JObject>();
        }

        public List<JObject> TestResources { get; }

        protected override void Emit(TemplateContext context, JObject resource)
        {
            base.Emit(context, resource);
            TestResources.Add(resource);
        }
    }
}
