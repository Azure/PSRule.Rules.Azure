// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A delegate that returns an Access Token.
/// </summary>
public delegate AccessToken GetAccessTokenFn(string tenantId);

/// <summary>
/// A helper to build a pipeline to export data from Azure.
/// </summary>
internal abstract class ExportDataPipelineBuilder : PipelineBuilderBase, IExportDataPipelineBuilder
{
    protected int _RetryCount;
    protected int _RetryInterval;

    protected GetAccessTokenFn _AccessToken;

    /// <inheritdoc/>
    public void AccessToken(GetAccessTokenFn fn)
    {
        _AccessToken = fn;
    }

    /// <inheritdoc/>
    public void RetryCount(int retryCount)
    {
        _RetryCount = retryCount;
    }

    /// <inheritdoc/>
    public void RetryInterval(int seconds)
    {
        _RetryInterval = seconds;
    }
}
