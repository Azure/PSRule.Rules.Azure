// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// An exception related to template linking.
/// </summary>
[Serializable]
public sealed class InvalidTemplateLinkException : PipelineException
{
    /// <summary>
    /// Creates a template linking exception.
    /// </summary>
    public InvalidTemplateLinkException()
    {
    }

    /// <summary>
    /// Creates a template linking exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    public InvalidTemplateLinkException(string message)
        : base(message) { }

    /// <summary>
    /// Creates a template linking exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    /// <param name="innerException">A nested exception that caused the issue.</param>
    public InvalidTemplateLinkException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create the exception from serialized data.
    /// </summary>
    private InvalidTemplateLinkException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }

    /// <summary>
    /// Serialize the exception.
    /// </summary>
    [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
    public override void GetObjectData(SerializationInfo info, StreamingContext context)
    {
        if (info == null)
            throw new ArgumentNullException(nameof(info));

        base.GetObjectData(info, context);
    }
}
