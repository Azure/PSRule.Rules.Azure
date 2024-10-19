// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace PSRule.Rules.Azure.Data.Template;

/// <summary>
/// An exception relating to a template parameter.
/// </summary>
[Serializable]
public sealed class TemplateParameterException : TemplateException
{
    /// <summary>
    /// Create an instance of a template parameter exception.
    /// </summary>
    public TemplateParameterException() { }

    /// <summary>
    /// Create an instance of a template parameter exception.
    /// </summary>
    public TemplateParameterException(string message)
        : base(message) { }

    /// <summary>
    /// Create an instance of a template parameter exception.
    /// </summary>
    public TemplateParameterException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create an instance of a template parameter exception.
    /// </summary>
    internal TemplateParameterException(string parameterName, string message)
        : base(message)
    {
        ParameterName = parameterName;
    }

    /// <summary>
    /// Create an instance of a template parameter exception.
    /// </summary>
    internal TemplateParameterException(string parameterName, string message, Exception innerException)
        : base(message, innerException)
    {
        ParameterName = parameterName;
    }

    /// <summary>
    /// Create an instance of a template parameter exception.
    /// </summary>
    private TemplateParameterException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }

    /// <summary>
    /// The name of the parameter.
    /// </summary>
    public string ParameterName { get; }

    /// <inheritdoc/>
    [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
    public override void GetObjectData(SerializationInfo info, StreamingContext context)
    {
        if (info == null) throw new ArgumentNullException(nameof(info));
        base.GetObjectData(info, context);
    }
}
