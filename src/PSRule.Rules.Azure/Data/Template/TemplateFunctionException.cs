// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace PSRule.Rules.Azure.Data.Template;

/// <summary>
/// An exception relating to a template function.
/// </summary>
[Serializable]
public sealed class TemplateFunctionException : TemplateException
{
    /// <summary>
    /// Create an instance of a template function exception.
    /// </summary>
    public TemplateFunctionException() { }

    /// <summary>
    /// Create an instance of a template function exception.
    /// </summary>
    public TemplateFunctionException(string message)
        : base(message) { }

    /// <summary>
    /// Create an instance of a template function exception.
    /// </summary>
    public TemplateFunctionException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create an instance of a template function exception.
    /// </summary>
    internal TemplateFunctionException(string functionName, FunctionErrorType errorType, string message)
        : base(message)
    {
        FunctionName = functionName;
        ErrorType = errorType;
    }

    /// <summary>
    /// Create an instance of a template function exception.
    /// </summary>
    internal TemplateFunctionException(string functionName, FunctionErrorType errorType, string message, Exception innerException)
        : base(message, innerException)
    {
        FunctionName = functionName;
        ErrorType = errorType;
    }

    /// <summary>
    /// Create an instance of a template function exception.
    /// </summary>
    private TemplateFunctionException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }

    /// <inheritdoc/>
    [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
    public override void GetObjectData(SerializationInfo info, StreamingContext context)
    {
        if (info == null) throw new ArgumentNullException(nameof(info));
        base.GetObjectData(info, context);
    }

    /// <summary>
    /// The name of the function.
    /// </summary>
    public string FunctionName { get; }

    /// <summary>
    /// The type of error raised.
    /// </summary>
    public FunctionErrorType ErrorType { get; }
}
