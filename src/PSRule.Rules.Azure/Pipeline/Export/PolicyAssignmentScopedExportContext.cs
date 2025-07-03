// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Pipeline.Export;

/// <summary>
/// A context for exporting policy assignments at a specific resource scope in Azure.
/// </summary>
internal sealed class PolicyAssignmentScopedExportContext : ExportDataContext
{
    private const string API_VERSION = "2023-04-01";

    private readonly string _ListAssignmentEndpoint;

    public PolicyAssignmentScopedExportContext(PipelineContext context, AccessTokenCache tokenCache, int retryCount, int retryInterval, string tenantId, string scopeId)
        : base(context, tokenCache, retryCount, retryInterval)
    {
        _ListAssignmentEndpoint = $"{RESOURCE_MANAGER_URL}{scopeId}/providers/Microsoft.Authorization/policyAssignments?api-version={API_VERSION}";
        TenantId = tenantId;
        RefreshToken(TenantId);
    }

    public string TenantId { get; }

    /// <inheritdoc/>
    public async Task<JObject[]> GetResourcesAsync()
    {
        return await ListAsync(TenantId, _ListAssignmentEndpoint, ignoreNotFound: false);
    }

    /// <inheritdoc/>
    public async Task<JObject> GetResourceAsync(string resourceId)
    {
        return await GetAsync(TenantId, $"{RESOURCE_MANAGER_URL}{resourceId}?api-version={API_VERSION}");
    }
}
