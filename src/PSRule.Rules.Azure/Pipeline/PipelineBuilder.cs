// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Configuration;

namespace PSRule.Rules.Azure.Pipeline;

internal delegate bool ShouldProcess(string target, string action);

/// <summary>
/// A helper class for building a pipeline from PowerShell.
/// </summary>
public static class PipelineBuilder
{
    /// <summary>
    /// Create a builder for a template expanding pipeline.
    /// </summary>
    /// <param name="option">Options that configure PSRule for Azure.</param>
    /// <returns>A builder object to configure the pipeline.</returns>
    public static ITemplatePipelineBuilder Template(PSRuleOption option)
    {
        return new TemplatePipelineBuilder(option);
    }

    /// <summary>
    /// Create a builder for a template link discovery pipeline.
    /// </summary>
    /// <param name="path">The base path to search from.</param>
    /// <returns>A builder object to configure the pipeline.</returns>
    public static ITemplateLinkPipelineBuilder TemplateLink(string path)
    {
        return new TemplateLinkPipelineBuilder(path);
    }

    /// <summary>
    /// Create a builder for a policy assignment export pipeline.
    /// </summary>
    /// <param name="option">Options that configure PSRule for Azure.</param>
    /// <returns>A builder object to configure the pipeline.</returns>
    public static IPolicyAssignmentPipelineBuilder Assignment(PSRuleOption option)
    {
        return new PolicyAssignmentPipelineBuilder(option);
    }

    /// <summary>
    /// Create a builder for a policy to rule generation pipeline.
    /// </summary>
    /// <param name="path">The base path to search from.</param>
    /// <returns>A builder object to configure the pipeline.</returns>
    public static IPolicyAssignmentSearchPipelineBuilder AssignmentSearch(string path)
    {
        return new PolicyAssignmentSearchPipelineBuilder(path);
    }

    /// <summary>
    /// Create a builder to export policy assignment data from Azure.
    /// </summary>
    /// <param name="options">>Options that configure PSRule for Azure.</param>
    /// <returns>A builder object to configure the pipeline.</returns>
    public static IPolicyAssignmentDataPipelineBuilder AssignmentData(PSRuleOption options)
    {
        return new PolicyAssignmentDataPipelineBuilder(options);
    }

    /// <summary>
    /// Create a builder for creating a pipeline to exporting resource data from Azure.
    /// </summary>
    /// <param name="option">Options that configure PSRule for Azure.</param>
    /// <returns>A builder object to configure the pipeline.</returns>
    public static IResourceDataPipelineBuilder ResourceData(PSRuleOption option)
    {
        return new ResourceDataPipelineBuilder(option);
    }
}
