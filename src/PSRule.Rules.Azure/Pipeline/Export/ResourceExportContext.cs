// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections.Concurrent;
using System.Threading;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Pipeline.Export;

/// <summary>
/// A context to export an Azure resource.
/// </summary>
internal class ResourceExportContext : ExportDataContext, IResourceExportContext
{
    private readonly ConcurrentQueue<JObject> _Resources;

    private bool _Disposed;

    public ResourceExportContext(PipelineContext context, AccessTokenCache tokenCache)
        : base(context, tokenCache) { }

    public ResourceExportContext(PipelineContext context, ConcurrentQueue<JObject> resources, AccessTokenCache tokenCache, int retryCount, int retryInterval)
        : base(context, tokenCache, retryCount, retryInterval)
    {
        _Resources = resources;
    }

    /// <inheritdoc/>
    public async Task<JObject> GetAsync(string tenantId, string requestUri, string apiVersion)
    {
        return await GetAsync(tenantId, GetEndpointUri(RESOURCE_MANAGER_URL, requestUri, apiVersion));
    }

    /// <inheritdoc/>
    public async Task<JObject[]> ListAsync(string tenantId, string requestUri, string apiVersion, bool ignoreNotFound)
    {
        return await ListAsync(tenantId, GetEndpointUri(RESOURCE_MANAGER_URL, requestUri, apiVersion), ignoreNotFound);
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
        while (!_Resources.IsEmpty)
        {
            WriteDiagnostics();
            RefreshAll();
            Thread.Sleep(100);
        }
    }
}
