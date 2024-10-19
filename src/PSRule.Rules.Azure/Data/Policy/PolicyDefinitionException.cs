// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using PSRule.Rules.Azure.Pipeline;

namespace PSRule.Rules.Azure.Data.Policy;

/// <summary>
/// A base class for exceptions processing policy definitions.
/// </summary>
[Serializable]
public abstract class PolicyDefinitionException : PipelineException
{
    /// <summary>
    /// Creates a policy definition exception.
    /// </summary>
    protected PolicyDefinitionException() { }

    /// <summary>
    /// Creates a policy definition exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    protected PolicyDefinitionException(string message)
        : base(message) { }

    /// <summary>
    /// Creates a policy definition exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    /// <param name="innerException">A nested exception that caused the issue.</param>
    protected PolicyDefinitionException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create the exception from serialized data.
    /// </summary>
    protected PolicyDefinitionException(SerializationInfo serializationInfo, StreamingContext streamingContext)
        : base(serializationInfo, streamingContext) { }
}
