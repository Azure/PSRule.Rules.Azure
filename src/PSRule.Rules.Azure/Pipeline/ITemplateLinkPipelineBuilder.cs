// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A helper to build a template link pipeline.
/// </summary>
public interface ITemplateLinkPipelineBuilder : IPipelineBuilder
{
    /// <summary>
    /// Determines if unlinked parameter files are skipped or error.
    /// </summary>
    void SkipUnlinked(bool skipUnlinked);
}
