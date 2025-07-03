// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Pipeline;

#nullable enable

/// <summary>
/// A builder to configure the pipeline to export data.
/// </summary>
public interface IExportDataPipelineBuilder : IPipelineBuilder
{
    /// <summary>
    /// Configures the tenant ID to use for the pipeline.
    /// If not specified, the tenant ID will be determined from the current credential or configuration.
    /// </summary>
    /// <param name="tenantId">A unique identifier as a GUID for the tenant.</param>
    void TenantId(string? tenantId);

    /// <summary>
    /// Configures a method to request an Access Token.
    /// </summary>
    void AccessToken(GetAccessTokenFn fn);

    /// <summary>
    /// The pipeline will retry operations that fail due to transient errors.
    /// This value specifies the number of times the pipeline will retry an operation before failing.
    /// </summary>
    void RetryCount(int? retryCount);

    /// <summary>
    /// The pipeline will retry operations that fail due to transient errors.
    /// This value specifies the default retry interval in seconds for the pipeline when the API does not specify a retry interval.
    /// If not specified, the default is 5 seconds.
    /// </summary>
    void RetryInterval(int? seconds);
}

#nullable restore
