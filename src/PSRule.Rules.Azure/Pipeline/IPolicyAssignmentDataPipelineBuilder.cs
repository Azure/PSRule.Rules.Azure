// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Pipeline;

#nullable enable

/// <summary>
/// A pipeline that exports data from Azure Policy assignments.
/// </summary>
public interface IPolicyAssignmentDataPipelineBuilder : IExportDataPipelineBuilder
{
    /// <summary>
    /// Optionally, specify a scope to query for policy assignments.
    /// </summary>
    /// <param name="scopeId"></param>
    void Scope(string[] scopeId);

    /// <summary>
    /// Optionally, specify the resource ID of a policy assignment to export.
    /// </summary>
    /// <param name="id"></param>
    void AssignmentId(string[] id);

    /// <summary>
    /// Specifies the path to write output.
    /// </summary>
    /// <param name="path">The directory path to write output.</param>
    void OutputPath(string path);

    /// <summary>
    /// Enable pass-through of output from the pipeline.
    /// </summary>
    /// <param name="passThru">Enable pass-through.</param>
    void PassThru(bool passThru);
}

#nullable restore
