// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace PSRule.Rules.Azure.Arm.Expressions;

/// <summary>
/// An exception caused by a failed deployment.
/// This exception only occurs when the template or module specifically calls fail().
/// </summary>
[Serializable]
public sealed class DeploymentFailureException : ExpressionException
{
    /// <summary>
    /// Create an instance of a deployment failure exception.
    /// </summary>
    public DeploymentFailureException() { }

    /// <summary>
    /// Create an instance of a deployment failure exception.
    /// </summary>
    public DeploymentFailureException(string message)
        : base(message) { }

    /// <summary>
    /// Create an instance of a deployment failure exception.
    /// </summary>
    public DeploymentFailureException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create an instance of a deployment failure exception.
    /// </summary>
    internal DeploymentFailureException(string expression, string message)
        : base(expression, message) { }

    /// <summary>
    /// Create an instance of a deployment failure exception.
    /// </summary>
    private DeploymentFailureException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }

    /// <inheritdoc/>
    [SecurityPermission(SecurityAction.Demand, SerializationFormatter = true)]
    public override void GetObjectData(SerializationInfo info, StreamingContext context)
    {
        if (info == null) throw new ArgumentNullException(nameof(info));
        base.GetObjectData(info, context);
    }
}
