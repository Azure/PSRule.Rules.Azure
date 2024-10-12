// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Management.Automation;

namespace PSRule.Rules.Azure.Pipeline;

internal interface ILogger
{
    void WriteVerbose(string message);

    void WriteVerbose(string format, params object[] args);

    void WriteWarning(string message);

    void WriteWarning(string format, params object[] args);

    void WriteError(Exception exception, string errorId, ErrorCategory errorCategory, object targetObject);
}
