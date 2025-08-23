// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Tool.Commands;

/// <summary>
/// Get a command results that does not include any output.
/// </summary>
public sealed class CommandResult(int exitCode)
{
    /// <summary>
    /// The numeric exit code of the command.
    /// </summary>
    public int ExitCode { get; } = exitCode;
}
