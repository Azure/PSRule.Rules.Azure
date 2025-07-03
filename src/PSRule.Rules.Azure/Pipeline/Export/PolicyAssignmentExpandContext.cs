// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Concurrent;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Pipeline.Export;

#nullable enable

/// <summary>
/// A context to export an Azure resource.
/// </summary>
internal sealed class PolicyAssignmentExpandContext(PipelineContext context, ConcurrentQueue<JObject> resources, AccessTokenCache tokenCache, int retryCount, int retryInterval, string tenantId)
    : ExportDataContext(context, tokenCache, retryCount, retryInterval), IPolicyAssignmentExpandContext
{
    private readonly ConcurrentQueue<JObject> _Resources = resources;

    private bool _Disposed;

    /// <inheritdoc/>
    public string TenantId { get; } = tenantId;

    /// <inheritdoc/>
    public async Task<JObject> GetAsync(string tenantId, string requestUri, string apiVersion, string? queryString)
    {
        return await GetAsync(tenantId, GetEndpointUri(RESOURCE_MANAGER_URL, requestUri, apiVersion, queryString));
    }

    /// <inheritdoc/>
    public async Task<JObject[]> ListAsync(string tenantId, string requestUri, string apiVersion, string? queryString, bool ignoreNotFound)
    {
        return await ListAsync(tenantId, GetEndpointUri(RESOURCE_MANAGER_URL, requestUri, apiVersion, queryString), ignoreNotFound);
    }

    protected override void Dispose(bool disposing)
    {
        if (!_Disposed)
        {
            if (disposing)
            {
                // Do nothing.
            }
            _Disposed = true;
        }
        base.Dispose(disposing);
    }

    internal void Flush()
    {
        WriteDiagnostics();
    }

    internal void Wait()
    {
        while (_Resources != null && !_Resources.IsEmpty)
        {
            WriteDiagnostics();
            RefreshAll();
            Thread.Sleep(100);
        }
    }
}

#nullable restore
