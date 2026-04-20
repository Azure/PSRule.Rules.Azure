// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Runtime.Serialization;
using PSRule.Rules.Azure.Pipeline;

namespace PSRule.Rules.Azure.Data.Terraform;

/// <summary>
/// An exception related to processing Terraform plan files.
/// </summary>
[Serializable]
public sealed class TerraformPlanException : PipelineException
{
    /// <summary>
    /// Creates a Terraform plan exception.
    /// </summary>
    public TerraformPlanException()
    {
    }

    /// <summary>
    /// Creates a Terraform plan exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    public TerraformPlanException(string message)
        : base(message) { }

    /// <summary>
    /// Creates a Terraform plan exception.
    /// </summary>
    /// <param name="message">The detail of the exception.</param>
    /// <param name="innerException">A nested exception that caused the issue.</param>
    public TerraformPlanException(string message, Exception innerException)
        : base(message, innerException) { }

    /// <summary>
    /// Create the exception from serialized data.
    /// </summary>
    private TerraformPlanException(SerializationInfo info, StreamingContext context)
        : base(info, context) { }
}
