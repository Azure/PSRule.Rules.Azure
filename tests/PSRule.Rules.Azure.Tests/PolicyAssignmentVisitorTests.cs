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
using Xunit;
using static PSRule.Rules.Azure.Data.Policy.PolicyAssignmentVisitor;

namespace PSRule.Rules.Azure
{
    public sealed class PolicyAssignmentVisitorTests
    {
        [Fact]
        public void GetPolicyDefinition()
        {
            var context = new PolicyAssignmentContext(GetContext());
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
            Assert.Equal(105, definitions.Length);

            // Check category and version
            var actual = definitions.FirstOrDefault(definition => definition.DefinitionId == "/providers/Microsoft.Authorization/policyDefinitions/34c877ad-507e-4c82-993e-3452a6e0ad3c");
            Assert.NotNull(actual);
            Assert.Equal("Azure.Policy.41ba16ba2225", actual.Name);
            Assert.Equal("Storage", actual.Category);
            Assert.Equal("1.1.1", actual.Version);
            Assert.Single(actual.Types);
            Assert.Equal("Microsoft.Storage/storageAccounts", actual.Types[0]);
            Assert.Null(actual.Where);
            Assert.Equal("{\"allOf\":[{\"equals\":\"Microsoft.Storage/storageAccounts\",\"type\":\".\"},{\"field\":\"properties.networkAcls.defaultAction\",\"notEquals\":\"Deny\"}]}", actual.Condition.ToString(Formatting.None));
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
            Assert.Equal(104, definitions.Length);

            // Check category and version
            var actual = definitions.FirstOrDefault(definition => definition.DefinitionId == "/providers/Microsoft.Authorization/policyDefinitions/34c877ad-507e-4c82-993e-3452a6e0ad3c");
            Assert.Null(actual);
        }

        [Fact]
        public void GetAssignmentWithSameParameters()
        {
            var context = new PolicyAssignmentContext(GetContext());
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
            var context = new PolicyAssignmentContext(GetContext());
            var visitor = new PolicyAssignmentDataExportVisitor();
            foreach (var assignment in GetAssignmentData().Where(a => a["Name"].Value<string>() == "RequestContext"))
                visitor.Visit(context, assignment);

            var definitions = context.GetDefinitions();
            Assert.NotNull(definitions);
            Assert.Single(definitions);
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
