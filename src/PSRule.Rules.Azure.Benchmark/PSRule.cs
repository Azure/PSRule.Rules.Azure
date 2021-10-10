// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Management.Automation;
using System.Reflection;
using BenchmarkDotNet.Attributes;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Pipeline;

namespace PSRule.Rules.Azure.Benchmark
{
    /// <summary>
    /// Define a set of benchmarks for performance testing PSRule internals.
    /// </summary>
    [MemoryDiagnoser]
    [MarkdownExporterAttribute.GitHub]
    public class PSRule
    {
        private IPipeline _TemplatePipeline;
        private PSObject _TemplateTemplate;
        private IPipeline _PropertyCopyLoopPipeline;
        private PSObject _PropertyCopyLoopTemplate;
        private IPipeline _UserDefinedFunctionsPipeline;
        private PSObject _UserDefinedFunctionsTemplate;

        [GlobalSetup]
        public void Prepare()
        {
            PrepareTemplatePipeline();
            PreparePropertyCopyLoopPipeline();
            PrepareUserDefinedFunctionsPipeline();
        }

        private void PrepareTemplatePipeline()
        {
            var builder = GetTemplatePipeline();
            _TemplatePipeline = builder.Build();
            _TemplateTemplate = PSObject.AsPSObject(new TemplateSource(
                templateFile: GetSourcePath("Template.1.json"),
                parametersFile: null
            ));
        }

        private void PreparePropertyCopyLoopPipeline()
        {
            var builder = GetTemplatePipeline();
            _PropertyCopyLoopPipeline = builder.Build();
            _PropertyCopyLoopTemplate = PSObject.AsPSObject(new TemplateSource(
                templateFile: GetSourcePath("Template.PropertyCopyLoop.json"),
                parametersFile: null
            ));
        }

        private void PrepareUserDefinedFunctionsPipeline()
        {
            var builder = GetTemplatePipeline();
            _UserDefinedFunctionsPipeline = builder.Build();
            _UserDefinedFunctionsTemplate = PSObject.AsPSObject(new TemplateSource(
                templateFile: GetSourcePath("Template.UserDefinedFunctions.json"),
                parametersFile: null
            ));
        }

        [Benchmark]
        public void Template()
        {
            RunPipelineTargets(_TemplatePipeline, _TemplateTemplate);
        }

        [Benchmark]
        public void PropertyCopyLoop()
        {
            RunPipelineTargets(_PropertyCopyLoopPipeline, _PropertyCopyLoopTemplate);
        }

        [Benchmark]
        public void UserDefinedFunctions()
        {
            RunPipelineTargets(_UserDefinedFunctionsPipeline, _UserDefinedFunctionsTemplate);
        }

        private void RunPipelineTargets(IPipeline pipeline, PSObject templateSource)
        {
            pipeline.Begin();
            for (var i = 0; i < 100; i++)
                pipeline.Process(templateSource);

            pipeline.End();
            if (pipeline is IDisposable d)
                d.Dispose();
        }

        private static string GetSourcePath(string fileName)
        {
            return Path.Combine(Path.GetDirectoryName(Assembly.GetEntryAssembly().Location), fileName);
        }

        private static ITemplatePipelineBuilder GetTemplatePipeline()
        {
            var option = PSRuleOption.FromFileOrDefault(GetSourcePath("ps-rule.yaml"));
            var builder = PipelineBuilder.Template(option);
            builder.PassThru(true);
            return builder;
        }
    }
}
