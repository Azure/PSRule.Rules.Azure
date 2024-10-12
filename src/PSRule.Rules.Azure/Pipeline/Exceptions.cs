// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A base class for all pipeline exceptions.
/// </summary>
public abstract class PipelineException : Exception
{
    /// <summary>
    /// Creates a pipeline exception.
    /// </summary>
    protected PipelineException()
    {
    }

    /// <summary>
    /// Creates a pipeline exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    protected PipelineException(string message)
        : base(message) { }

    /// <summary>
    /// Creates a pipeline exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    /// <param name="innerException">A nested exception that caused the issue.</param>
    protected PipelineException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create the exception from serialized data.
    /// </summary>
    protected PipelineException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }
}

/// <summary>
/// A serialization exception.
/// </summary>
[Serializable]
public sealed class PipelineSerializationException : PipelineException
{
    /// <summary>
    /// Creates a serialization exception.
    /// </summary>
    public PipelineSerializationException()
    {
    }

    /// <summary>
    /// Creates a serialization exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    public PipelineSerializationException(string message)
        : base(message) { }

    /// <summary>
    /// Creates a serialization exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    /// <param name="innerException">A nested exception that caused the issue.</param>
    public PipelineSerializationException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create the exception from serialized data.
    /// </summary>
    private PipelineSerializationException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }

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

/// <summary>
/// An exception related to template linking.
/// </summary>
[Serializable]
public sealed class InvalidTemplateLinkException : PipelineException
{
    /// <summary>
    /// Creates a template linking exception.
    /// </summary>
    public InvalidTemplateLinkException()
    {
    }

    /// <summary>
    /// Creates a template linking exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    public InvalidTemplateLinkException(string message)
        : base(message) { }

    /// <summary>
    /// Creates a template linking exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    /// <param name="innerException">A nested exception that caused the issue.</param>
    public InvalidTemplateLinkException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create the exception from serialized data.
    /// </summary>
    private InvalidTemplateLinkException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }

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

/// <summary>
/// An exception related to compiling Bicep source files.
/// </summary>
[Serializable]
public sealed class BicepCompileException : PipelineException
{
    /// <summary>
    /// Creates a Bicep compile exception.
    /// </summary>
    public BicepCompileException()
    {
    }

    /// <summary>
    /// Creates a Bicep compile exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    public BicepCompileException(string message)
        : base(message) { }

    /// <summary>
    /// Creates a Bicep compile exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    /// <param name="innerException">A nested exception that caused the issue.</param>
    public BicepCompileException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Creates a Bicep compile exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    /// <param name="innerException">A nested exception that caused the issue.</param>
    /// <param name="sourceFile">The path to the Bicep source file.</param>
    /// <param name="version">Specifies the version of Bicep runtime being used.</param>
    internal BicepCompileException(string message, Exception innerException, string sourceFile, string version)
        : base(message, innerException)
    {
        SourceFile = sourceFile;
        Version = version;
    }

    /// <summary>
    /// Create the exception from serialized data.
    /// </summary>
    private BicepCompileException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }

    /// <summary>
    /// The file path to an Azure Bicep source file.
    /// </summary>
    public string SourceFile { get; }

    /// <summary>
    /// The version of the Bicep binary.
    /// </summary>
    public string Version { get; }

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
