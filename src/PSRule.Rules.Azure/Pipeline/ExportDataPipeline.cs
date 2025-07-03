// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using PSRule.Rules.Azure.Pipeline.Export;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A base class for a pipeline that exports data from Azure.
/// </summary>
internal abstract class ExportDataPipeline(PipelineContext context, string tenantId, GetAccessTokenFn getToken, int retryCount, int retryInterval, string outputPath) : PipelineBase(context)
{
    private bool _Disposed;

    protected int RetryCount { get; } = retryCount;

    protected int RetryInterval { get; } = retryInterval;

    protected string OutputPath { get; } = outputPath;

    protected string TenantId { get; } = tenantId;

    /// <summary>
    /// The number of threads to expand the pipeline for parallel processing.
    /// </summary>
    protected int PoolSize { get; } = Environment.ProcessorCount >= 4 ? Environment.ProcessorCount : 4;

    protected AccessTokenCache TokenCache { get; } = new AccessTokenCache(getToken);

    protected override void Dispose(bool disposing)
    {
        if (!_Disposed)
        {
            if (disposing)
            {
                TokenCache.Dispose();
            }
            _Disposed = true;
        }
        base.Dispose(disposing);
    }
}
