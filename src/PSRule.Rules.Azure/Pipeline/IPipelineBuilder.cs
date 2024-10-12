// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Management.Automation;
using PSRule.Rules.Azure.Configuration;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A helper to build a PSRule for Azure pipeline.
/// </summary>
public interface IPipelineBuilder
{
    /// <summary>
    /// Configure the pipeline with cmdlet runtime information.
    /// </summary>
    void UseCommandRuntime(PSCmdlet commandRuntime);

    /// <summary>
    /// Configure the pipeline with a PowerShell execution context.
    /// </summary>
    void UseExecutionContext(EngineIntrinsics executionContext);

    /// <summary>
    /// Configure the pipeline with options.
    /// </summary>
    /// <param name="option">Options that configure PSRule for Azure.</param>
    /// <returns></returns>
    IPipelineBuilder Configure(PSRuleOption option);

    /// <summary>
    /// Build the pipeline.
    /// </summary>
    /// <returns>An instance of a configured pipeline.</returns>
    IPipeline Build();
}
