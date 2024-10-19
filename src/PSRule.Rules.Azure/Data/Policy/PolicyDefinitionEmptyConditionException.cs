// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using System.Security.Permissions;

namespace PSRule.Rules.Azure.Data.Policy;

/// <summary>
/// An exception that occurs when a policy definition returns no valid rule condition.
/// </summary>
[Serializable]
public sealed class PolicyDefinitionEmptyConditionException : PolicyDefinitionException
{
    /// <summary>
    /// Creates an empty condition exception.
    /// </summary>
    public PolicyDefinitionEmptyConditionException() { }

    /// <summary>
    /// Creates an empty condition exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    public PolicyDefinitionEmptyConditionException(string message)
        : base(message) { }

    /// <summary>
    /// Creates an empty condition exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    /// <param name="innerException">A nested exception that caused the issue.</param>
    public PolicyDefinitionEmptyConditionException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Creates an empty condition exception based on an assignment and policy definition.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    /// <param name="sourceFile">The source file.</param>
    /// <param name="assignmentId">Specifies Id of the assignment the exception relates to.</param>
    /// <param name="policyDefinitionId">Specifies the Id of the policy definition the exception relates to.</param>
    internal PolicyDefinitionEmptyConditionException(string message, string sourceFile, string assignmentId, string policyDefinitionId)
        : base(message, null)
    {
        AssignmentId = assignmentId;
        PolicyDefinitionId = policyDefinitionId;
    }

    /// <summary>
    /// Create the exception from serialized data.
    /// </summary>
    private PolicyDefinitionEmptyConditionException(SerializationInfo serializationInfo, StreamingContext streamingContext)
        : base(serializationInfo, streamingContext) { }

    /// <summary>
    /// The unique identifier for the assignment within Azure.
    /// </summary>
    public string AssignmentId { get; }

    /// <summary>
    /// The unique identifer for the policy definition within Azure.
    /// </summary>
    public string PolicyDefinitionId { get; }

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
