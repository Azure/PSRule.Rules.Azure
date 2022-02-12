// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Management.Automation;
using System.Text;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Data.Template;
using PSRule.Rules.Azure.Pipeline.Output;

namespace PSRule.Rules.Azure.Pipeline
{
    public interface ITemplatePipelineBuilder : IPipelineBuilder
    {
        void Deployment(string deploymentName);

        void ResourceGroup(ResourceGroupOption resourceGroup);

        void Subscription(SubscriptionOption subscription);

        void PassThru(bool passThru);
    }

    internal sealed class TemplatePipelineBuilder : PipelineBuilderBase, ITemplatePipelineBuilder
    {
        private const string OUTPUTFILE_PREFIX = "resources-";
        private const string OUTPUTFILE_EXTENSION = ".json";
        private const string DEPLOYMENTNAME_PREFIX = "export-";

        private string _DeploymentName;
        private bool _PassThru;

        internal TemplatePipelineBuilder(PSRuleOption option)
            : base()
        {
            _DeploymentName = string.Concat(DEPLOYMENTNAME_PREFIX, Guid.NewGuid().ToString().Substring(0, 8));
            Configure(option);
        }

        public void Deployment(string deploymentName)
        {
            if (string.IsNullOrEmpty(deploymentName))
                return;

            _DeploymentName = deploymentName;
        }

        public void ResourceGroup(ResourceGroupOption resourceGroup)
        {
            if (resourceGroup == null)
                return;

            Option.Configuration.ResourceGroup = ResourceGroupOption.Combine(resourceGroup, Option.Configuration.ResourceGroup);
        }

        public void Subscription(SubscriptionOption subscription)
        {
            if (subscription == null)
                return;

            Option.Configuration.Subscription = SubscriptionOption.Combine(subscription, Option.Configuration.Subscription);
        }

        public void PassThru(bool passThru)
        {
            _PassThru = passThru;
        }

        protected override PipelineWriter GetOutput()
        {
            // Redirect to file instead
            return !string.IsNullOrEmpty(Option.Output.Path)
                ? new FileOutputWriter(
                    inner: base.GetOutput(),
                    option: Option,
                    encoding: GetEncoding(Option.Output.Encoding),
                    path: Option.Output.Path,
                    defaultFile: string.Concat(OUTPUTFILE_PREFIX, _DeploymentName, OUTPUTFILE_EXTENSION),
                    shouldProcess: CmdletContext.ShouldProcess
                )
                : base.GetOutput();
        }

        protected override PipelineWriter PrepareWriter()
        {
            return _PassThru ? base.PrepareWriter() : new JsonOutputWriter(GetOutput(), Option);
        }

        public override IPipeline Build()
        {
            return new TemplatePipeline(PrepareContext(), _DeploymentName);
        }

        /// <summary>
        /// Get the character encoding for the specified output encoding.
        /// </summary>
        /// <param name="encoding"></param>
        /// <returns></returns>
        private static Encoding GetEncoding(OutputEncoding? encoding)
        {
            switch (encoding)
            {
                case OutputEncoding.UTF8:
                    return Encoding.UTF8;

                case OutputEncoding.UTF7:
                    return Encoding.UTF7;

                case OutputEncoding.Unicode:
                    return Encoding.Unicode;

                case OutputEncoding.UTF32:
                    return Encoding.UTF32;

                case OutputEncoding.ASCII:
                    return Encoding.ASCII;

                default:
                    return new UTF8Encoding(encoderShouldEmitUTF8Identifier: false);
            }
        }
    }

    internal sealed class TemplatePipeline : PipelineBase
    {
        private readonly TemplateHelper _TemplateHelper;

        internal TemplatePipeline(PipelineContext context, string deploymentName)
            : base(context)
        {
            _TemplateHelper = new TemplateHelper(context, deploymentName);
        }

        public override void Process(PSObject sourceObject)
        {
            if (sourceObject == null || !(sourceObject.BaseObject is TemplateSource source))
                return;

            if (source.ParametersFile == null || source.ParametersFile.Length == 0)
                ProcessCatch(source.TemplateFile, null);
            else
                for (var i = 0; i < source.ParametersFile.Length; i++)
                    ProcessCatch(source.TemplateFile, source.ParametersFile[i]);
        }

        private void ProcessCatch(string templateFile, string parameterFile)
        {
            try
            {
                Context.Writer.WriteObject(ProcessTemplate(templateFile, parameterFile), true);
            }
            catch (PipelineException ex)
            {
                Context.Writer.WriteError(ex, nameof(PipelineException), ErrorCategory.InvalidData, parameterFile);
            }
            catch
            {
                throw;
            }
        }

        internal PSObject[] ProcessTemplate(string templateFile, string parameterFile)
        {
            return _TemplateHelper.ProcessTemplate(templateFile, parameterFile, out _);
        }
    }
}
