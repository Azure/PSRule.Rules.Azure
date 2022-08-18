// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.


using System;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Pipeline.Output;

namespace PSRule.Rules.Azure.Pipeline
{
    /// <summary>
    /// A builder for a policy assignment export pipeline.
    /// </summary>
    public interface IPolicyAssignmentPipelineBuilder : IPipelineBuilder
    {
        /// <summary>
        /// Enable pass-through of output from the pipeline.
        /// </summary>
        /// <param name="passThru">Enable pass-through.</param>
        void PassThru(bool passThru);
    }

    internal sealed class PolicyAssignmentPipelineBuilder : PipelineBuilderBase, IPolicyAssignmentPipelineBuilder
    {
        private bool _PassThru;
        private const string OUTPUTFILE_PREFIX = "definitions-";
        private const string OUTPUTFILE_EXTENSION = ".Rule.jsonc";
        private const string ASSIGNMENTNAME_PREFIX = "export-";
        private string _AssignmentName;

        internal PolicyAssignmentPipelineBuilder(PSRuleOption option)
        {
            _AssignmentName = string.Concat(ASSIGNMENTNAME_PREFIX, Guid.NewGuid().ToString().Substring(0, 8));
            Configure(option);
        }

        public void Assignment(string assignmentName)
        {
            if (string.IsNullOrEmpty(assignmentName))
                return;

            _AssignmentName = assignmentName;
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

        /// <inheritdoc/>
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
                    encoding: Option.Output.Encoding.GetEncoding(),
                    path: Option.Output.Path,
                    defaultFile: string.Concat(OUTPUTFILE_PREFIX, _AssignmentName, OUTPUTFILE_EXTENSION),
                    shouldProcess: CmdletContext.ShouldProcess
                )
                : base.GetOutput();
        }

        protected override PipelineWriter PrepareWriter()
        {
            return _PassThru ? base.PrepareWriter() : new JsonOutputWriter(GetOutput(), Option);
        }

        /// <inheritdoc/>
        public override IPipeline Build()
        {
            return new PolicyAssignmentPipeline(PrepareContext());
        }
    }
}
