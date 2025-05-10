// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using System.Security.Permissions;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Arm.Expressions;

/// <summary>
/// An exception relating to expression evaluation.
/// </summary>
[Serializable]
public sealed class ExpressionEvaluationException : TemplateException
{
    /// <summary>
    /// Create an instance of an expression evaluation exception.
    /// </summary>
    public ExpressionEvaluationException() { }

    /// <summary>
    /// Create an instance of an expression evaluation exception.
    /// </summary>
    public ExpressionEvaluationException(string message)
        : base(message) { }

    /// <summary>
    /// Create an instance of an expression evaluation exception.
    /// </summary>
    public ExpressionEvaluationException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create an instance of an expression evaluation exception.
    /// </summary>
    internal ExpressionEvaluationException(string expression, string message)
        : base(message)
    {
        Expression = expression;
    }

    /// <summary>
    /// Create an instance of an expression evaluation exception.
    /// </summary>
    internal ExpressionEvaluationException(string expression, string message, Exception innerException)
        : base(message, innerException)
    {
        Expression = expression;
    }

    /// <summary>
    /// Create an instance of an expression evaluation exception.
    /// </summary>
    private ExpressionEvaluationException(SerializationInfo info, StreamingContext context)
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
