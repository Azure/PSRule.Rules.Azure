// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Pipeline.Export;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A base class for a pipeline that exports data from Azure.
/// </summary>
internal abstract class ExportDataPipeline : PipelineBase
{
    private bool _Disposed;

    protected ExportDataPipeline(PipelineContext context, GetAccessTokenFn getToken)
        : base(context)
    {
        PoolSize = 10;
        TokenCache = new AccessTokenCache(getToken);
    }

    /// <summary>
    /// The size of the thread pool for the pipeline.
    /// </summary>
    protected int PoolSize { get; }

    protected AccessTokenCache TokenCache { get; }

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
