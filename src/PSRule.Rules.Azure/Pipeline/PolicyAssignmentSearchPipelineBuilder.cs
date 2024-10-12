// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Pipeline;

internal sealed class PolicyAssignmentSearchPipelineBuilder : PipelineBuilderBase, IPolicyAssignmentSearchPipelineBuilder
{
    private readonly string _BasePath;

    internal PolicyAssignmentSearchPipelineBuilder(string basePath)
    {
        _BasePath = basePath;
    }

    /// <inheritdoc/>
    public override IPipeline Build()
    {
        return new PolicyAssignmentSearchPipeline(PrepareContext(), _BasePath);
    }
}
