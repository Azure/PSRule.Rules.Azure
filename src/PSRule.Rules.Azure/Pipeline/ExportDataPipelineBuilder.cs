// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace PSRule.Rules.Azure.Pipeline;

#nullable enable

/// <summary>
/// A helper to build a pipeline to export data from Azure.
/// </summary>
internal abstract class ExportDataPipelineBuilder : PipelineBuilderBase, IExportDataPipelineBuilder
{
    private string? _TenantId;

    protected int? _RetryCount;
    protected int? _RetryInterval;

    protected GetAccessTokenFn? _AccessToken;

    /// <inheritdoc/>
    public void TenantId(string? tenantId)
    {
        if (string.IsNullOrWhiteSpace(tenantId))
            return;

        _TenantId = tenantId;
    }

    /// <inheritdoc/>
    public void AccessToken(GetAccessTokenFn fn)
    {
        _AccessToken = fn ?? throw new ArgumentNullException(nameof(fn));
    }

    /// <inheritdoc/>
    public void RetryCount(int? retryCount)
    {
        _RetryCount = retryCount;
    }

    /// <inheritdoc/>
    public void RetryInterval(int? seconds)
    {
        _RetryInterval = seconds;
    }

    /// <summary>
    /// Try to determine the tenant ID that will be used for the pipeline.
    /// </summary>
    protected string? GetTenantId()
    {
        return GetTenantIdFromParameters() ??
            GetTenantIdFromConfiguration() ??
            GetTenantIdFromCurrentCredential();
    }

    protected int GetRetryCount()
    {
        return _RetryCount ?? 5;
    }

    protected int GetRetryInterval()
    {
        return _RetryInterval ?? 5;
    }

    protected virtual string? GetTenantIdFromCurrentCredential()
    {
        return default;
    }

    private string? GetTenantIdFromConfiguration()
    {
        return default;
    }

    private string? GetTenantIdFromParameters()
    {
        return _TenantId;
    }
}

#nullable restore
