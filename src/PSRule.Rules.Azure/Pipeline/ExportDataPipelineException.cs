// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A base class for exceptions processing policy definitions.
/// </summary>
[Serializable]
public abstract class ExportDataPipelineException : PipelineException
{
    /// <summary>
    /// Creates a policy definition exception.
    /// </summary>
    protected ExportDataPipelineException() { }

    /// <summary>
    /// Creates a policy definition exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    protected ExportDataPipelineException(string message)
        : base(message) { }

    /// <summary>
    /// Creates a policy definition exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    /// <param name="innerException">A nested exception that caused the issue.</param>
    protected ExportDataPipelineException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create the exception from serialized data.
    /// </summary>
    protected ExportDataPipelineException(SerializationInfo serializationInfo, StreamingContext streamingContext)
        : base(serializationInfo, streamingContext) { }
}
