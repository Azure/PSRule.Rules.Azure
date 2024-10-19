// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace PSRule.Rules.Azure.Pipeline;

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
