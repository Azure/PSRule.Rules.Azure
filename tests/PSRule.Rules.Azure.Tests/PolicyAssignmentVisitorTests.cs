// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Linq;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Policy;
using PSRule.Rules.Azure.Pipeline;
using static PSRule.Rules.Azure.Data.Policy.PolicyAssignmentVisitor;

namespace PSRule.Rules.Azure
{
    public sealed class PolicyAssignmentVisitorTests
    {
        [Fact]
        public void GetPolicyDefinition()
        {
            var context = new PolicyAssignmentContext(GetContext(), keepDuplicates: true);
            var visitor = new PolicyAssignmentDataExportVisitor();
            foreach (var assignment in GetAssignmentData())
            {
                try
                {
                    visitor.Visit(context, assignment);
                }
                catch
                {
                    // Sink exceptions, currently there are bugs that need to be fixed.
                }
            }

            var definitions = context.GetDefinitions();
            Assert.NotNull(definitions);
            Assert.Equal(130, definitions.Length);

            // Check category and version
            var actual = definitions.FirstOrDefault(definition => definition.DefinitionId == "/providers/Microsoft.Authorization/policyDefinitions/34c877ad-507e-4c82-993e-3452a6e0ad3c");
            Assert.NotNull(actual);
            Assert.Equal("Azure.Policy.ff989b7c6a22", actual.Name);
            Assert.Equal("Storage", actual.Category);
            Assert.Equal("1.1.1", actual.Version);
            Assert.Single(actual.Types);
            Assert.Equal("Microsoft.Storage/storageAccounts", actual.Types[0]);
            Assert.Null(actual.Where);
            Assert.Equal("{\"field\":\"properties.networkAcls.defaultAction\",\"equals\":\"Deny\"}", actual.Condition.ToString(Formatting.None));
            Assert.Equal(new string[] { "PSRule.Rules.Azure\\Azure.Policy.Indexed" }, actual.With);

            actual = definitions.FirstOrDefault(definition => definition.DefinitionId == "/providers/Microsoft.Authorization/policyDefinitions/04c4380f-3fae-46e8-96c9-30193528f602");
            Assert.NotNull(actual);
            Assert.Equal("Azure.Policy.4e24c971a1ac", actual.Name);
            Assert.Equal("Monitoring", actual.Category);
            Assert.Equal("1.0.2-preview", actual.Version);
            Assert.Single(actual.Types);
            Assert.Equal("Microsoft.Compute/virtualMachines", actual.Types[0]);
            Assert.Equal("{\"anyOf\":[{\"allOf\":[{\"field\":\"properties.storageProfile.imageReference.publisher\",\"equals\":\"Canonical\"},{\"field\":\"properties.storageProfile.imageReference.offer\",\"equals\":\"UbuntuServer\"},{\"anyOf\":[{\"field\":\"properties.storageProfile.imageReference.sku\",\"in\":[\"18.04-LTS\",\"16.04-LTS\",\"16.04.0-LTS\",\"14.04.0-LTS\",\"14.04.1-LTS\",\"14.04.5-LTS\"]}]}]},{\"allOf\":[{\"field\":\"properties.storageProfile.imageReference.publisher\",\"equals\":\"RedHat\"},{\"field\":\"properties.storageProfile.imageReference.offer\",\"in\":[\"RHEL\",\"RHEL-SAP-HANA\"]},{\"anyOf\":[{\"field\":\"properties.storageProfile.imageReference.sku\",\"like\":\"6.*\"},{\"field\":\"properties.storageProfile.imageReference.sku\",\"like\":\"7*\"}]}]},{\"allOf\":[{\"field\":\"properties.storageProfile.imageReference.publisher\",\"equals\":\"SUSE\"},{\"field\":\"properties.storageProfile.imageReference.offer\",\"in\":[\"SLES\",\"SLES-HPC\",\"SLES-HPC-Priority\",\"SLES-SAP\",\"SLES-SAP-BYOS\",\"SLES-Priority\",\"SLES-BYOS\",\"SLES-SAPCAL\",\"SLES-Standard\"]},{\"field\":\"properties.storageProfile.imageReference.sku\",\"in\":[\"12-SP2\",\"12-SP3\",\"12-SP4\"]}]},{\"allOf\":[{\"field\":\"properties.storageProfile.imageReference.publisher\",\"equals\":\"OpenLogic\"},{\"field\":\"properties.storageProfile.imageReference.offer\",\"in\":[\"CentOS\",\"Centos-LVM\",\"CentOS-SRIOV\"]},{\"anyOf\":[{\"field\":\"properties.storageProfile.imageReference.sku\",\"like\":\"6.*\"},{\"field\":\"properties.storageProfile.imageReference.sku\",\"like\":\"7*\"}]}]},{\"allOf\":[{\"field\":\"properties.storageProfile.imageReference.publisher\",\"equals\":\"cloudera\"},{\"field\":\"properties.storageProfile.imageReference.offer\",\"equals\":\"cloudera-centos-os\"},{\"field\":\"properties.storageProfile.imageReference.sku\",\"like\":\"7*\"}]}]}", actual.Where.ToString(Formatting.None));
            Assert.Equal(new string[] { "PSRule.Rules.Azure\\Azure.Policy.Indexed" }, actual.With);

            actual = definitions.FirstOrDefault(definition => definition.DefinitionId == "/providers/Microsoft.Authorization/policyDefinitions/f9be5368-9bf5-4b84-9e0a-7850da98bb46");
            Assert.NotNull(actual);
            Assert.Equal("Azure.Policy.2289f9ccdf2b", actual.Name);
            Assert.Equal("Stream Analytics", actual.Category);
            Assert.Equal("5.0.0", actual.Version);
            Assert.Single(actual.Types);
            Assert.Equal("Microsoft.StreamAnalytics/streamingJobs", actual.Types[0]);
            var condition = actual.Condition.ToString(Formatting.None);
            Assert.Equal("{\"field\":\"resources\",\"allOf\":[{\"greaterOrEqual\":1,\"field\":\"properties.logs[*]\",\"anyOf\":[{\"allOf\":[{\"field\":\"retentionPolicy.enabled\",\"equals\":\"true\"},{\"anyOf\":[{\"field\":\"retentionPolicy.days\",\"equals\":\"0\"},{\"value\":{\"$\":{\"padLeft\":{\"path\":\"retentionPolicy.days\"},\"totalLength\":3,\"paddingCharacter\":\"0\"}},\"greaterOrEquals\":365,\"convert\":true}]},{\"field\":\"enabled\",\"equals\":\"true\"}]},{\"allOf\":[{\"field\":\"enabled\",\"equals\":\"true\"},{\"anyOf\":[{\"field\":\"retentionPolicy.enabled\",\"notEquals\":\"true\"},{\"field\":\"properties.storageAccountId\",\"exists\":false}]}]}]}],\"where\":{\"type\":\".\",\"equals\":\"Microsoft.Insights/diagnosticSettings\"}}", actual.Condition.ToString(Formatting.None));
            Assert.Equal(new string[] { "PSRule.Rules.Azure\\Azure.Policy.Indexed" }, actual.With);
        }

        [Fact]
        public void GetPolicyDefinitionWithIgnore()
        {
            var options = new PSRuleOption();
            options.Configuration.PolicyIgnoreList = new string[]
            {
                "/providers/Microsoft.Authorization/policyDefinitions/34c877ad-507e-4c82-993e-3452a6e0ad3c"
            };
            var context = new PolicyAssignmentContext(GetContext(options));
            var visitor = new PolicyAssignmentDataExportVisitor();
            foreach (var assignment in GetAssignmentData())
            {
                try
                {
                    visitor.Visit(context, assignment);
                }
                catch
                {
                    // Sink exceptions, currently there are bugs that need to be fixed.
                }
            }

            var definitions = context.GetDefinitions();
            Assert.NotNull(definitions);
            Assert.Equal(111, definitions.Length);

            // Check category and version
            var actual = definitions.FirstOrDefault(definition => definition.DefinitionId == "/providers/Microsoft.Authorization/policyDefinitions/34c877ad-507e-4c82-993e-3452a6e0ad3c");
            Assert.Null(actual);
        }

        [Fact]
        public void GetAssignmentWithSameParameters()
        {
            var context = new PolicyAssignmentContext(GetContext(), keepDuplicates: true);
            var visitor = new PolicyAssignmentDataExportVisitor();
            foreach (var assignment in GetAssignmentData().Where(a => a["Name"].Value<string>().StartsWith("CustomAllowedLocations-")))
            {
                try
                {
                    visitor.Visit(context, assignment);
                }
                catch
                {
                    // Sink exceptions, currently there are bugs that need to be fixed.
                }
            }

            var definitions = context.GetDefinitions();
            Assert.NotNull(definitions);
            Assert.Equal(2, definitions.Length);
        }

        [Fact]
        public void ConvertRequestContext()
        {
            var context = new PolicyAssignmentContext(GetContext(), keepDuplicates: true);
            var visitor = new PolicyAssignmentDataExportVisitor();
            foreach (var assignment in GetAssignmentData().Where(a => a["Name"].Value<string>() == "RequestContext"))
                visitor.Visit(context, assignment);

            var definitions = context.GetDefinitions();
            Assert.NotNull(definitions);
            Assert.Single(definitions);
        }

        [Fact]
        public void GetResourceGroupLocation()
        {
            var context = new PolicyAssignmentContext(GetContext(), keepDuplicates: true);
            var visitor = new PolicyAssignmentDataExportVisitor();
            foreach (var assignment in GetAssignmentData("Policy.assignment.2.json").Where(a => a["Name"].Value<string>() == "8a3e449a009c485b930b36f2"))
                visitor.Visit(context, assignment);

            var definitions = context.GetDefinitions();
            Assert.NotNull(definitions);
            Assert.Single(definitions);

            var actual = definitions.FirstOrDefault(definition => definition.DefinitionId == "/providers/Microsoft.Authorization/policyDefinitions/e765b5de-1225-4ba3-bd56-1ac6695af988");
            Assert.NotNull(actual);
            Assert.Equal("Azure.Policy.8fc87228ae18", actual.Name);
            Assert.Equal("Allowed locations for resource groups", actual.DisplayName);
            Assert.Equal("This policy enables you to restrict the locations your organization can create resource groups in. Use to enforce your geo-compliance requirements.", actual.Recommendation);
            Assert.Equal("General", actual.Category);
            Assert.Equal("1.0.0", actual.Version);
            Assert.Single(actual.Types);
            Assert.Equal("Microsoft.Resources/resourceGroups", actual.Types[0]);
            Assert.Null(actual.Where);
            Assert.Equal("{\"field\":\"location\",\"in\":[\"australiaeast\",\"australiasoutheast\",\"eastus\",\"westus\"]}", actual.Condition.ToString(Formatting.None));
            Assert.Equal(new string[] { "PSRule.Rules.Azure\\Azure.Policy.All" }, actual.With);
        }

        [Fact]
        public void Expand_field_with_concat()
        {
            var context = new PolicyAssignmentContext(GetContext(), keepDuplicates: true);
            var visitor = new PolicyAssignmentDataExportVisitor();
            foreach (var assignment in GetAssignmentData("Policy.assignment.3.json").Where(a => a["Name"].Value<string>() == "eba0bb3d870549789539e7d2"))
                visitor.Visit(context, assignment);

            var definitions = context.GetDefinitions();
            Assert.NotNull(definitions);
            Assert.Single(definitions);

            var actual = definitions.FirstOrDefault(definition => definition.DefinitionId == "/providers/Microsoft.Authorization/policyDefinitions/96670d01-0a4d-4649-9c89-2d3abc0a5025");
            Assert.NotNull(actual);
            Assert.Equal("Azure.Policy.6db2a8060ade", actual.Name);
            Assert.Equal("Require a tag on resource groups", actual.DisplayName);
            Assert.Equal("Enforces existence of a tag on resource groups.", actual.Synopsis);
            Assert.Equal("Enforces existence of a tag on resource groups.", actual.Recommendation);
            Assert.Equal("Tags", actual.Category);
            Assert.Equal("1.0.0", actual.Version);
            Assert.Single(actual.Types);
            Assert.Equal("Microsoft.Resources/resourceGroups", actual.Types[0]);
            Assert.Null(actual.Where);
            Assert.Equal("{\"field\":\"tags['env']\",\"exists\":true}", actual.Condition.ToString(Formatting.None));
            Assert.Equal(new string[] { "PSRule.Rules.Azure\\Azure.Policy.All" }, actual.With);
        }

        [Fact]
        public void Ensure_visitor_generates_baseline()
        {
            var context = new PolicyAssignmentContext(GetContext());
            var visitor = new PolicyAssignmentDataExportVisitor();
            foreach (var assignment in GetAssignmentData().Where(a => a["Name"].Value<string>() == "RequestContext" || a["Name"].Value<string>() == "CustomAllowedLocations-australiaeast"))
                visitor.Visit(context, assignment);

            var baseline = context.GenerateBaseline();

            Assert.Equal("Azure.PolicyBaseline.All", baseline.Name);
            Assert.Equal("Generated automatically when exporting Azure Policy rules.", baseline.Description);
            Assert.Equal(new string[] { "Azure.Policy.b8a4e2d03e09", "PSRule.Rules.Azure\\Azure.KeyVault.SoftDelete" }, baseline.Include);
        }

        /// <summary>
        /// This tests for a reverse cases where the child extension is audit if a setting on the parent resource is set.
        /// </summary>
        [Fact]
        public void GetParentAudit()
        {
            var context = new PolicyAssignmentContext(GetContext());
            var visitor = new PolicyAssignmentDataExportVisitor();
            foreach (var assignment in GetAssignmentData("Policy.assignment.4.json").Where(a => a["Name"].Value<string>() == "assignment.4"))
                visitor.Visit(context, assignment);

            var definitions = context.GetDefinitions();
            Assert.NotNull(definitions);
            Assert.Single(definitions);

            var actual = definitions.FirstOrDefault(definition => definition.DefinitionId == "/providers/Microsoft.Authorization/policyDefinitions/d26f7642-7545-4e18-9b75-8c9bbdee3a9a");
            Assert.NotNull(actual);
            Assert.Single(actual.Types);
            Assert.Equal("Microsoft.Compute/virtualMachines", actual.Types[0]);
            Assert.Null(actual.Where);
            Assert.Equal("{\"field\":\"identity.type\",\"contains\":\"SystemAssigned\"}", actual.Condition.ToString(Formatting.None));
            Assert.Equal(new string[] { "PSRule.Rules.Azure\\Azure.Policy.Indexed" }, actual.With);
        }

        [Fact]
        public void Expand_policy_details_name()
        {
            var context = new PolicyAssignmentContext(GetContext());
            var visitor = new PolicyAssignmentDataExportVisitor();
            foreach (var assignment in GetAssignmentData("Policy.assignment.5.json").Where(a => a["Name"].Value<string>() == "assignment.5"))
                visitor.Visit(context, assignment);

            var definitions = context.GetDefinitions();
            Assert.NotNull(definitions);
            Assert.Single(definitions);

            var actual = definitions.FirstOrDefault(definition => definition.DefinitionId == "/providers/Microsoft.Authorization/policyDefinitions/bef3f64c-5290-43b7-85b0-9b254eef4c47");
            Assert.NotNull(actual);
            Assert.Single(actual.Types);
            Assert.Equal("Microsoft.KeyVault/vaults", actual.Types[0]);
            Assert.Null(actual.Where);
            Assert.Equal("{\"allOf\":[{\"type\":\".\",\"equals\":\"Microsoft.Insights/diagnosticSettings\"},{\"name\":\".\",\"equals\":\"setbypolicy_logAnalytics\"}]}", actual.Condition["where"].ToString(Formatting.None));
            Assert.Equal(new string[] { "PSRule.Rules.Azure\\Azure.Policy.Indexed" }, actual.With);
        }

        [Fact]
        public void Expand_field_with_less()
        {
            var context = new PolicyAssignmentContext(GetContext());
            var visitor = new PolicyAssignmentDataExportVisitor();
            foreach (var assignment in GetAssignmentData("Policy.assignment.6.json").Where(a => a["Name"].Value<string>() == "assignment.6"))
                visitor.Visit(context, assignment);

            var definitions = context.GetDefinitions();
            Assert.NotNull(definitions);
            Assert.Single(definitions);

            var actual = definitions.FirstOrDefault(definition => definition.DefinitionId == "/providers/Microsoft.Authorization/policyDefinitions/817dcf37-e83d-4999-a472-644eada2ea1e");
            Assert.NotNull(actual);
            Assert.Single(actual.Types);
            Assert.Equal("Microsoft.Web/hostingEnvironments", actual.Types[0]);
            Assert.Equal("{\"allOf\":[{\"field\":\"kind\",\"like\":\"ASE*\"},{\"less\":1,\"field\":\"properties.clusterSettings[*]\",\"allOf\":[{\"field\":\"name\",\"contains\":\"FrontEndSSLCipherSuiteOrder\"},{\"field\":\"value\",\"contains\":\"TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384\"},{\"field\":\"value\",\"contains\":\"TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256\"},{\"field\":\"value\",\"less\":80,\"convert\":true}]}]}", actual.Where.ToString(Formatting.None));
        }

        [Fact]
        public void Visit_ShouldComplete_WhenLengthField()
        {
            var context = new PolicyAssignmentContext(GetContext());
            var visitor = new PolicyAssignmentDataExportVisitor();
            foreach (var assignment in GetAssignmentData("Policy.assignment.7.json").Where(a => a["Name"].Value<string>() == "assignment.7"))
                visitor.Visit(context, assignment);

            var definitions = context.GetDefinitions();
            Assert.NotNull(definitions);
            Assert.Equal(2, definitions.Length);

            var actual = definitions.FirstOrDefault(definition => definition.DefinitionId == "/providers/Microsoft.Management/managementGroups/mg-01/providers/Microsoft.Authorization/policyDefinitions/00000000-0000-0000-0000-000000000001");
            Assert.NotNull(actual);
            Assert.Single(actual.Types);
            Assert.Equal("Microsoft.KeyVault/Vaults", actual.Types[0]);
            Assert.Equal("{\"anyOf\":[{\"exists\":false,\"field\":\"properties.networkAcls.defaultAction\"},{\"equals\":\"Allow\",\"field\":\"properties.networkAcls.defaultAction\"},{\"exists\":false,\"field\":\"properties.networkAcls.virtualNetworkRules\"},{\"field\":\"properties.networkAcls.virtualNetworkRules\",\"notCount\":0},{\"exists\":false,\"field\":\"properties.networkAcls.ipRules\"},{\"field\":\"properties.networkAcls.ipRules\",\"notCount\":0}]}", actual.Where.ToString(Formatting.None));

            actual = definitions.FirstOrDefault(definition => definition.DefinitionId == "/providers/Microsoft.Management/managementGroups/mg-01/providers/Microsoft.Authorization/policyDefinitions/00000000-0000-0000-0000-000000000002");
            Assert.NotNull(actual);
            Assert.Single(actual.Types);
            Assert.Equal("Microsoft.Storage/storageAccounts", actual.Types[0]);
            Assert.Equal("{\"anyOf\":[{\"exists\":false,\"field\":\"properties.networkAcls.defaultAction\"},{\"equals\":\"Allow\",\"field\":\"properties.networkAcls.defaultAction\"},{\"exists\":false,\"field\":\"properties.networkAcls.virtualNetworkRules\"},{\"field\":\"properties.networkAcls.virtualNetworkRules\",\"notCount\":0},{\"exists\":false,\"field\":\"properties.networkAcls.ipRules\"},{\"field\":\"properties.networkAcls.ipRules\",\"notCount\":0}]}", actual.Where.ToString(Formatting.None));
        }

        [Fact]
        public void Visit_ShouldComplete_WhenSplitConcatField()
        {
            var context = new PolicyAssignmentContext(GetContext());
            var visitor = new PolicyAssignmentDataExportVisitor();
            foreach (var assignment in GetAssignmentData("Policy.assignment.8.json").Where(a => a["Name"].Value<string>() == "assignment.8"))
                visitor.Visit(context, assignment);

            var definitions = context.GetDefinitions();
            Assert.NotNull(definitions);
            Assert.Single(definitions);

            var actual = definitions.FirstOrDefault();
            Assert.Single(actual.Types);
            Assert.Equal("Microsoft.Storage/storageAccounts/privateEndpointConnections", actual.Types[0]);
            var temp = actual.Where.ToString(Formatting.None);
            Assert.Equal("{\"anyOf\":[{\"exists\":false,\"field\":\"properties.privateEndpoint.id\"},{\"notEquals\":\"ffffffff-ffff-ffff-ffff-ffffffffffff\",\"value\":{\"$\":{\"split\":{\"concat\":[{\"path\":\"properties.privateEndpoint.id\"},{\"string\":\"//\"}]},\"delimiter\":[\"/\"]}}}]}", temp);
        }

        [Fact]
        public void Visit_ShouldReturnFormattedSynopsis_WhenMultiLineDescription()
        {
            var context = new PolicyAssignmentContext(GetContext());
            var visitor = new PolicyAssignmentDataExportVisitor();
            foreach (var assignment in GetAssignmentData("Policy.assignment.9.json").Where(a => a["Name"].Value<string>() == "assignment.9"))
                visitor.Visit(context, assignment);

            var definitions = context.GetDefinitions();
            Assert.NotNull(definitions);
            Assert.Single(definitions);

            var actual = definitions.FirstOrDefault(definition => definition.DefinitionId == "/providers/Microsoft.Authorization/policyDefinitions/policyDefinition.1");
            Assert.Equal("Microsoft Defender for Azure Cosmos DB is an Azure-native layer of security that detects attempts to exploit databases in your Azure Cosmos DB accounts.", actual.Synopsis);
            Assert.Equal("Microsoft Defender for Azure Cosmos DB is an Azure-native layer of security that detects attempts to exploit databases in your Azure Cosmos DB accounts.\nDefender for Azure Cosmos DB detects potential SQL injections, known bad actors based on Microsoft Threat Intelligence, suspicious access patterns, and potential exploitations of your database through compromised identities or malicious insiders.", actual.Recommendation);
        }

        #region Helper methods

        private static PipelineContext GetContext(PSRuleOption option = null)
        {
            return new PipelineContext(option ?? new PSRuleOption(), null);
        }

        private static string GetSourcePath(string fileName)
        {
            return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, fileName);
        }

        private static JObject[] GetAssignmentData(string fileName = "Policy.assignment.json")
        {
            var path = GetSourcePath(fileName);
            var json = File.ReadAllText(path);
            return JsonConvert.DeserializeObject<JObject[]>(json);
        }

        #endregion Helper methods
    }
}
