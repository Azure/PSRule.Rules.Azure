// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using System.Security.Permissions;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Arm.Expressions;

/// <summary>
/// A base class for an exception relating to an expression.
/// </summary>
public abstract class ExpressionException : TemplateException
{
    /// <summary>
    /// Create an instance of an expression exception.
    /// </summary>
    protected ExpressionException() { }

    /// <summary>
    /// Create an instance of an expression exception.
    /// </summary>
    protected ExpressionException(string message)
        : base(message) { }

    /// <summary>
    /// Create an instance of an expression exception.
    /// </summary>
    protected ExpressionException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create an instance of an expression exception.
    /// </summary>
    protected ExpressionException(string expression, string message)
        : base(message)
    {
        Expression = expression;
    }

    /// <summary>
    /// Create an instance of an expression exception.
    /// </summary>
    protected ExpressionException(string expression, string message, Exception innerException)
        : base(message, innerException)
    {
        Expression = expression;
    }

    /// <summary>
    /// Create an instance of an expression exception.
    /// </summary>
    protected ExpressionException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }

    /// <summary>
    /// The expression that caused the exception.
    /// </summary>
    public string Expression { get; }

    /// <inheritdoc/>
    [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
    public override void GetObjectData(SerializationInfo info, StreamingContext context)
    {
        if (info == null) throw new ArgumentNullException(nameof(info));
        base.GetObjectData(info, context);
    }
}
