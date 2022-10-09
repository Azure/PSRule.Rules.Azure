// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Pipeline.Output;

namespace PSRule.Rules.Azure.Pipeline
{
    /// <summary>
    /// A helper for building a template expansion pipeline.
    /// </summary>
    public interface ITemplatePipelineBuilder : IPipelineBuilder
    {
        /// <summary>
        /// Configures the name of the deployment.
        /// </summary>
        void Deployment(string deploymentName);

        /// <summary>
        /// Configures properties of the resource group.
        /// </summary>
        void ResourceGroup(ResourceGroupOption resourceGroup);

        /// <summary>
        /// Configures properties of the subscription.
        /// </summary>
        void Subscription(SubscriptionOption subscription);

        /// <summary>
        /// Determines if expanded resources are passed through to the pipeline.
        /// </summary>
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

        /// <inheritdoc/>
        public void Deployment(string deploymentName)
        {
            if (string.IsNullOrEmpty(deploymentName))
                return;

            Option.Configuration.Deployment = new DeploymentOption(deploymentName);
            _DeploymentName = deploymentName;
        }

        /// <inheritdoc/>
        public void ResourceGroup(ResourceGroupOption resourceGroup)
        {
            if (resourceGroup == null)
                return;

            Option.Configuration.ResourceGroup = ResourceGroupOption.Combine(resourceGroup, Option.Configuration.ResourceGroup);
        }

        /// <inheritdoc/>
        public void Subscription(SubscriptionOption subscription)
        {
            if (subscription == null)
                return;

            Option.Configuration.Subscription = SubscriptionOption.Combine(subscription, Option.Configuration.Subscription);
        }

        /// <inheritdoc/>
        public void PassThru(bool passThru)
        {
            _PassThru = passThru;
        }

        /// <inheritdoc/>
        protected override PipelineWriter GetOutput()
        {
            // Redirect to file instead
            return !string.IsNullOrEmpty(Option.Output.Path)
                ? new FileOutputWriter(
                    inner: base.GetOutput(),
                    option: Option,
                    encoding: Option.Output.Encoding.GetEncoding(),
                    path: Option.Output.Path,
                    defaultFile: string.Concat(OUTPUTFILE_PREFIX, _DeploymentName, OUTPUTFILE_EXTENSION),
                    shouldProcess: CmdletContext.ShouldProcess
                )
                : base.GetOutput();
        }

        /// <inheritdoc/>
        protected override PipelineWriter PrepareWriter()
        {
            return _PassThru ? base.PrepareWriter() : new JsonOutputWriter(GetOutput(), Option);
        }

        /// <inheritdoc/>
        public override IPipeline Build()
        {
            return new TemplatePipeline(PrepareContext());
        }
    }
}
