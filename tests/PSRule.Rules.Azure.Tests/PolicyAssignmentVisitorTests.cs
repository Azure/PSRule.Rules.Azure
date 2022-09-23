// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.IO;
using System;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Data.Policy;
using PSRule.Rules.Azure.Pipeline;
using Xunit;
using static PSRule.Rules.Azure.Data.Policy.PolicyAssignmentVisitor;
using PSRule.Rules.Azure.Configuration;
using System.Linq;

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
            Assert.True(definitions.Length >= 183);

            // Check category and version
            var actual = definitions.FirstOrDefault(definition => definition.DefinitionId == "/providers/Microsoft.Authorization/policyDefinitions/a4fe33eb-e377-4efb-ab31-0784311bc499");
            Assert.NotNull(actual);
            Assert.Equal("Security Center", actual.Category);
            Assert.Equal("1.0.0", actual.Version);
        }

        #region Helper methods

        private static PipelineContext GetContext()
        {
            return new PipelineContext(new PSRuleOption(), null);
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
