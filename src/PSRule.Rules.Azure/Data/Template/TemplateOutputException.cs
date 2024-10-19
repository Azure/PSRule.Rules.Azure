// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace PSRule.Rules.Azure.Data.Template;

/// <summary>
/// An exception relating to a template output.
/// </summary>
[Serializable]
public sealed class TemplateOutputException : TemplateException
{
    /// <summary>
    /// Create an instance of a template output exception.
    /// </summary>
    public TemplateOutputException() { }

    /// <summary>
    /// Create an instance of a template output exception.
    /// </summary>
    public TemplateOutputException(string message)
        : base(message) { }

    /// <summary>
    /// Create an instance of a template output exception.
    /// </summary>
    public TemplateOutputException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create an instance of a template output exception.
    /// </summary>
    internal TemplateOutputException(string outputName, string message)
        : base(message)
    {
        OutputName = outputName;
    }

    /// <summary>
    /// Create an instance of a template output exception.
    /// </summary>
    internal TemplateOutputException(string outputName, string message, Exception innerException)
        : base(message, innerException)
    {
        OutputName = outputName;
    }

    /// <summary>
    /// Create an instance of a template output exception.
    /// </summary>
    private TemplateOutputException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }

    /// <summary>
    /// The name of the output.
    /// </summary>
    public string OutputName { get; }

    /// <inheritdoc/>
    [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
    public override void GetObjectData(SerializationInfo info, StreamingContext context)
    {
        if (info == null) throw new ArgumentNullException(nameof(info));
        base.GetObjectData(info, context);
    }
}
