// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace PSRule.Rules.Azure.Arm.Expressions;

/// <summary>
/// An exception relating to expression arguments.
/// </summary>
[Serializable]
public sealed class ExpressionArgumentException : ExpressionException
{
    /// <summary>
    /// Create an instance of an expression argument exception.
    /// </summary>
    public ExpressionArgumentException() { }

    /// <summary>
    /// Create an instance of an expression argument exception.
    /// </summary>
    public ExpressionArgumentException(string message)
        : base(message) { }

    /// <summary>
    /// Create an instance of an expression argument exception.
    /// </summary>
    public ExpressionArgumentException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create an instance of an expression argument exception.
    /// </summary>
    internal ExpressionArgumentException(string expression, string message)
        : base(expression, message) { }

    /// <summary>
    /// Create an instance of an expression argument exception.
    /// </summary>
    private ExpressionArgumentException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }

    /// <inheritdoc/>
    [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
    public override void GetObjectData(SerializationInfo info, StreamingContext context)
    {
        if (info == null) throw new ArgumentNullException(nameof(info));
        base.GetObjectData(info, context);
    }
}
