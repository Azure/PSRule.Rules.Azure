// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using System.Security.Permissions;
using PSRule.Rules.Azure.Data.Template;

namespace PSRule.Rules.Azure.Arm.Deployments;

#nullable enable

/// <summary>
/// An exception relating to evaluating a deployment.
/// </summary>
[Serializable]
public sealed class DeploymentEvaluationException : TemplateException
{
    /// <summary>
    /// Create an instance of a deployment evaluation exception.
    /// </summary>
    public DeploymentEvaluationException() { }

    /// <summary>
    /// Create an instance of a deployment evaluation exception.
    /// </summary>
    public DeploymentEvaluationException(string message)
        : base(message) { }

    /// <summary>
    /// Create an instance of a deployment evaluation exception.
    /// </summary>
    public DeploymentEvaluationException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create an instance of a deployment evaluation exception.
    /// </summary>
    internal DeploymentEvaluationException(string? symbolicName, string deploymentName, string message)
        : base(message)
    {
        SymbolicName = symbolicName;
        DeploymentName = deploymentName;
    }

    /// <summary>
    /// Create an instance of a deployment evaluation exception.
    /// </summary>
    internal DeploymentEvaluationException(string? symbolicName, string deploymentName, string message, Exception innerException)
        : base(message, innerException)
    {
        SymbolicName = symbolicName;
        DeploymentName = deploymentName;
    }

    /// <summary>
    /// Create an instance of a deployment evaluation exception.
    /// </summary>
    private DeploymentEvaluationException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }

    /// <summary>
    /// The name of the symbol.
    /// </summary>
    public string? SymbolicName { get; }

    /// <summary>
    /// The name of the deployment.
    /// </summary>
    public string? DeploymentName { get; }

    /// <inheritdoc/>
    [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
    public override void GetObjectData(SerializationInfo info, StreamingContext context)
    {
        if (info == null) throw new ArgumentNullException(nameof(info));
        base.GetObjectData(info, context);
    }
}

#nullable restore
