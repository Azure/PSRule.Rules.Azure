// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Pipeline
{
    public interface IPolicyAssignmentSearchPipelineBuilder : IPipelineBuilder
    {

    }

    internal sealed class PolicyAssignmentSearchPipelineBuilder : PipelineBuilderBase, IPolicyAssignmentSearchPipelineBuilder
    {
        private readonly string _BasePath;

        internal PolicyAssignmentSearchPipelineBuilder(string basePath)
        {
            _BasePath = basePath;
        }

        public override IPipeline Build()
        {
            return new PolicyAssignmentSearchPipeline(PrepareContext(), _BasePath);
        }
    }
}