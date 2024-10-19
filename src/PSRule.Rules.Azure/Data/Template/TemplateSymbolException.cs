// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace PSRule.Rules.Azure.Data.Template;

/// <summary>
/// An exception relating to a template symbol.
/// </summary>
[Serializable]
public sealed class TemplateSymbolException : TemplateException
{
    /// <summary>
    /// Create an instance of a template symbol exception.
    /// </summary>
    public TemplateSymbolException() { }

    /// <summary>
    /// Create an instance of a template symbol exception.
    /// </summary>
    public TemplateSymbolException(string message)
        : base(message) { }

    /// <summary>
    /// Create an instance of a template symbol exception.
    /// </summary>
    public TemplateSymbolException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create an instance of a template symbol exception.
    /// </summary>
    internal TemplateSymbolException(string symbolicName, string message)
        : base(message)
    {
        SymbolicName = symbolicName;
    }

    /// <summary>
    /// Create an instance of a template symbol exception.
    /// </summary>
    internal TemplateSymbolException(string symbolicName, string message, Exception innerException)
        : base(message, innerException)
    {
        SymbolicName = symbolicName;
    }

    /// <summary>
    /// Create an instance of a template symbol exception.
    /// </summary>
    private TemplateSymbolException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }

    /// <summary>
    /// The name of the symbol.
    /// </summary>
    public string SymbolicName { get; }

    /// <inheritdoc/>
    [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
    public override void GetObjectData(SerializationInfo info, StreamingContext context)
    {
        if (info == null) throw new ArgumentNullException(nameof(info));
        base.GetObjectData(info, context);
    }
}
