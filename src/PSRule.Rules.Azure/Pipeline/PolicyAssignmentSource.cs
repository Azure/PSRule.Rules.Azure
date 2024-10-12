// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A policy assignment source file.
/// </summary>
public sealed class PolicyAssignmentSource
{
    /// <summary>
    /// The assignment source file.
    /// </summary>
    public string AssignmentFile { get; }

    /// <summary>
    /// Create an assignment instance.
    /// </summary>
    /// <param name="assignmentFile">The assignment source file.</param>
    public PolicyAssignmentSource(string assignmentFile)
    {
        AssignmentFile = assignmentFile;
    }
}
