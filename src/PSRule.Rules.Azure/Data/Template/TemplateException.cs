// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using PSRule.Rules.Azure.Pipeline;

namespace PSRule.Rules.Azure.Data.Template;

/// <summary>
/// A base class for an exception relating to a template.
/// </summary>
public abstract class TemplateException : PipelineException
{
    /// <summary>
    /// Create an instance of a template exception.
    /// </summary>
    protected TemplateException() { }

    /// <summary>
    /// Create an instance of a template exception.
    /// </summary>
    protected TemplateException(string message)
        : base(message) { }

    /// <summary>
    /// Create an instance of a template exception.
    /// </summary>
    protected TemplateException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create an instance of a template exception.
    /// </summary>
    protected TemplateException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }
}
