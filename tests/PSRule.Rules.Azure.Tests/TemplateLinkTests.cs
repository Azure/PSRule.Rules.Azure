// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Pipeline;
using System;
using System.IO;
using System.Management.Automation;
using Xunit;

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

        private static string GetSourcePath(string fileName)
        {
            return Path.Combine(AppDomain.CurrentDomain.BaseDirectory, fileName);
        }

        private static IPipeline NewPipeline()
        {
            var builder = PipelineBuilder.TemplateLink(AppDomain.CurrentDomain.BaseDirectory);
            return builder.Build();
        }
    }
}
