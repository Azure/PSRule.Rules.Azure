// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Management.Automation;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Pipeline;

namespace PSRule.Rules.Azure
{
    public sealed class TemplateLinkTests
    {
        [Fact]
        public void Pipeline()
        {
            var pipeline = NewPipeline();
            pipeline.Begin();
            pipeline.Process(PSObject.AsPSObject(GetSourcePath("Resources.Parameters.json")));
            pipeline.Process(PSObject.AsPSObject(new FileInfo(GetSourcePath("Resources.Parameters.json"))));
            pipeline.End();
        }

        [Fact]
        public void GetBicepParameters()
        {
            var helper = new TemplateLinkHelper(GetContext(), AppDomain.CurrentDomain.BaseDirectory, true);

            // From metadata
            var link = helper.ProcessParameterFile(GetSourcePath("Tests.Bicep.1.metalink.json"));
            Assert.NotNull(link);
            Assert.NotNull(link.TemplateFile);
            Assert.EndsWith("Tests.Bicep.1.bicep", link.TemplateFile);
            Assert.NotNull(link.ParameterFile);
            Assert.EndsWith("Tests.Bicep.1.metalink.json", link.ParameterFile);

            // From naming convention
            link = helper.ProcessParameterFile(GetSourcePath("Tests.Bicep.1.parameters.json"));
            Assert.NotNull(link);
            Assert.NotNull(link.TemplateFile);
            Assert.EndsWith("Tests.Bicep.1.bicep", link.TemplateFile);
            Assert.NotNull(link.ParameterFile);
            Assert.EndsWith("Tests.Bicep.1.parameters.json", link.ParameterFile);

            // From naming convention when both .bicep and .json exist
            link = helper.ProcessParameterFile(GetSourcePath("Tests.Bicep.2.parameters.json"));
            Assert.NotNull(link);
            Assert.NotNull(link.TemplateFile);
            Assert.EndsWith("Tests.Bicep.2.json", link.TemplateFile);
            Assert.NotNull(link.ParameterFile);
            Assert.EndsWith("Tests.Bicep.2.parameters.json", link.ParameterFile);
        }

        #region Helper methods

        private static string GetSourcePath(string fileName)
        {
            return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, fileName);
        }

        private static IPipeline NewPipeline()
        {
            var builder = PipelineBuilder.TemplateLink(AppDomain.CurrentDomain.BaseDirectory);
            return builder.Build();
        }

        private static PipelineContext GetContext()
        {
            return new PipelineContext(GetOption(), null);
        }

        private static PSRuleOption GetOption()
        {
            return PSRuleOption.Default;
        }

        #endregion Helper methods
    }
}
