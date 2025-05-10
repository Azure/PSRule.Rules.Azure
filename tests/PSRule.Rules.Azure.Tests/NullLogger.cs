// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Management.Automation;
using PSRule.Rules.Azure.Pipeline;

namespace PSRule.Rules.Azure;

internal sealed class NullLogger : ILogger
{
    public void WriteError(Exception exception, string errorId, ErrorCategory errorCategory, object targetObject)
    {
        // Do nothing
    }

    public void WriteVerbose(string message)
    {
        // Do nothing
    }

    public void WriteVerbose(string format, params object[] args)
    {
        // Do nothing
    }
    public void WriteWarning(string message)
    {
        // Do nothing
    }

    public void WriteWarning(string format, params object[] args)
    {
        // Do nothing
    }
}
