// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.IO;
using System.Management.Automation;
using System.Reflection;
using BenchmarkDotNet.Attributes;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Policy;
using PSRule.Rules.Azure.Data.Template;
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
        private static readonly string[] POLICY_ALIAS = new string[] {
            "Microsoft.Storage/storageAccounts/minimumTlsVersion",
            "Microsoft.Web/sites/slots/config/appSettings",
            "Microsoft.Compute/virtualMachineScaleSets/virtualMachines/storageProfile.dataDisks"
        };

        private IPipeline _TemplatePipeline;
        private PSObject _TemplateTemplate;
        private IPipeline _PropertyCopyLoopPipeline;
        private PSObject _PropertyCopyLoopTemplate;
        private IPipeline _UserDefinedFunctionsPipeline;
        private PSObject _UserDefinedFunctionsTemplate;
        private PolicyAliasProviderHelper _PolicyAliasProviderHelper;
        private ResourceProviderHelper _ResourceProviderHelper;
        private CustomTypeTopologyGraph _CustomTypeDependencyGraph;

        #region Setup

        [GlobalSetup]
        public void Prepare()
        {
            PrepareTemplatePipeline();
            PreparePropertyCopyLoopPipeline();
            PrepareUserDefinedFunctionsPipeline();
            PrepareResolvePolicyAliasPath();
            PrepareGetResourceType();
            PrepareCustomTypeDependencyGraph();
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

        private void PrepareResolvePolicyAliasPath()
        {
            _PolicyAliasProviderHelper = new PolicyAliasProviderHelper();
        }

        private void PrepareGetResourceType()
        {
            _ResourceProviderHelper = new ResourceProviderHelper();
        }

        private void PrepareCustomTypeDependencyGraph()
        {
            _CustomTypeDependencyGraph = new CustomTypeTopologyGraph();
            _CustomTypeDependencyGraph.Add("base", GetCustomTypeObject());
            _CustomTypeDependencyGraph.Add("nestedComplexType", GetCustomTypeObject("complexType"));
            _CustomTypeDependencyGraph.Add("basicType", GetCustomTypeObject("object"));
            _CustomTypeDependencyGraph.Add("object", GetCustomTypeObject());
            _CustomTypeDependencyGraph.Add("array", GetCustomTypeObject("object"));
            _CustomTypeDependencyGraph.Add("complexType", GetCustomTypeObject("array"));
            _CustomTypeDependencyGraph.Add("newBase", GetCustomTypeObject());
        }

        #endregion Setup

        #region Benchmarks

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

        [Benchmark]
        public void ResolvePolicyAliasPath()
        {
            _PolicyAliasProviderHelper.ResolvePolicyAliasPath(POLICY_ALIAS[0], out _);
            _PolicyAliasProviderHelper.ResolvePolicyAliasPath(POLICY_ALIAS[1], out _);
            _PolicyAliasProviderHelper.ResolvePolicyAliasPath(POLICY_ALIAS[2], out _);
        }

        [Benchmark]
        public void GetResourceType()
        {
            _ResourceProviderHelper.GetResourceType("Microsoft.Compute", "virtualMachines");
            _ResourceProviderHelper.GetResourceType("Microsoft.ContainerService", "managedClusters");
        }

        [Benchmark]
        public void CustomTypeDependencyGraph_GetOrdered()
        {
            _CustomTypeDependencyGraph.GetOrdered();
        }

        #endregion Benchmarks

        #region Helper methods

        private static void RunPipelineTargets(IPipeline pipeline, PSObject templateSource)
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

        private static JObject GetCustomTypeObject(string ancestor = null)
        {
            return ancestor == null ? new JObject() : JObject.Parse(string.Concat("{ \"$ref\": \"#/definitions/", ancestor, "\"}"));
        }

        #endregion Helpers methods
    }
}
