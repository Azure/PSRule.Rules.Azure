// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Pipeline;

internal sealed class TemplateLinkPipelineBuilder : PipelineBuilderBase, ITemplateLinkPipelineBuilder
{
    private readonly string _BasePath;

    private bool _SkipUnlinked;

    internal TemplateLinkPipelineBuilder(string basePath)
    {
        _BasePath = basePath;
    }

    /// <inheritdoc/>
    public void SkipUnlinked(bool skipUnlinked)
    {
        _SkipUnlinked = skipUnlinked;
    }

    /// <inheritdoc/>
    public override IPipeline Build()
    {
        return new TemplateLinkPipeline(PrepareContext(), _BasePath, _SkipUnlinked);
    }
}
