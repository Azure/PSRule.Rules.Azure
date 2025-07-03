// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A serialization exception.
/// </summary>
[Serializable]
public sealed class ResourceDataPipelineException : ExportDataPipelineException
{
    /// <summary>
    /// Creates a serialization exception.
    /// </summary>
    public ResourceDataPipelineException()
    {
    }

    /// <summary>
    /// Creates a serialization exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    public ResourceDataPipelineException(string message)
        : base(message) { }

    /// <summary>
    /// Creates a serialization exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    /// <param name="innerException">A nested exception that caused the issue.</param>
    public ResourceDataPipelineException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create the exception from serialized data.
    /// </summary>
    private ResourceDataPipelineException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }

    /// <summary>
    /// Serialize the exception.
    /// </summary>
    [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
    public override void GetObjectData(SerializationInfo info, StreamingContext context)
    {
        if (info == null) throw new ArgumentNullException(nameof(info));

        base.GetObjectData(info, context);
    }
}
