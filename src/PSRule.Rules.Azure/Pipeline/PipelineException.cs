// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A base class for all pipeline exceptions.
/// </summary>
public abstract class PipelineException : Exception
{
    /// <summary>
    /// Creates a pipeline exception.
    /// </summary>
    protected PipelineException()
    {
    }

    /// <summary>
    /// Creates a pipeline exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    protected PipelineException(string message)
        : base(message) { }

    /// <summary>
    /// Creates a pipeline exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    /// <param name="innerException">A nested exception that caused the issue.</param>
    protected PipelineException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create the exception from serialized data.
    /// </summary>
    protected PipelineException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }
}
