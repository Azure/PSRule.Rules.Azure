// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Management.Automation;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// An instance of a PSRule for Azure pipeline.
/// </summary>
public interface IPipeline
{
    /// <summary>
    /// Initialize the pipeline and results. Call this method once prior to calling Process.
    /// </summary>
    void Begin();

    /// <summary>
    /// Process an object through the pipeline.
    /// </summary>
    /// <param name="sourceObject">The object to process.</param>
    void Process(PSObject sourceObject);

    /// <summary>
    /// Clean up and flush pipeline results. Call this method once after processing any objects through the pipeline.
    /// </summary>
    [System.Diagnostics.CodeAnalysis.SuppressMessage("Naming", "CA1716:Identifiers should not match keywords", Justification = "Matches PowerShell pipeline.")]
    void End();
}
