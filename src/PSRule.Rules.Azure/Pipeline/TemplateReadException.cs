// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// An exception related to reading templates.
/// </summary>
[Serializable]
public sealed class TemplateReadException : PipelineException
{
    /// <summary>
    /// Creates a template read exception.
    /// </summary>
    public TemplateReadException()
    {
    }

    /// <summary>
    /// Creates a template read exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    public TemplateReadException(string message)
        : base(message) { }

    /// <summary>
    /// Creates a template read exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    /// <param name="innerException">A nested exception that caused the issue.</param>
    public TemplateReadException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Creates a template read exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    /// <param name="innerException">A nested exception that caused the issue.</param>
    /// <param name="templateFile">The path to the ARM template file that is being used.</param>
    /// <param name="parameterFile">The path to the ARM template parameter file that is being used.</param>
    internal TemplateReadException(string message, Exception innerException, string templateFile, string parameterFile)
        : this(message, innerException)
    {
        TemplateFile = templateFile;
        ParameterFile = parameterFile;
    }

    /// <summary>
    /// Create the exception from serialized data.
    /// </summary>
    private TemplateReadException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }

    /// <summary>
    /// The file path to an Azure Template.
    /// </summary>
    public string TemplateFile { get; }

    /// <summary>
    /// The file path to an Azure Template parameter file.
    /// </summary>
    public string ParameterFile { get; }

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
