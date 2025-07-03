// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Arm;
using PSRule.Rules.Azure.Data;

namespace PSRule.Rules.Azure.Pipeline.Export;

/// <summary>
/// A context to export an Azure subscription.
/// </summary>
internal sealed class SubscriptionExportContext : ExportDataContext, ISubscriptionExportContext
{
    private readonly string _ResourceEndpoint;
    private readonly string _ResourceGroupEndpoint;
    private readonly string _SubscriptionEndpoint;

    private ProviderData _ProviderData;

    /// <summary>
    /// Create a context to export an Azure subscription.
    /// </summary>
    public SubscriptionExportContext(PipelineContext context, ExportSubscriptionScope scope, AccessTokenCache tokenCache, Hashtable tag)
        : base(context, tokenCache)
    {
        _ResourceEndpoint = $"{RESOURCE_MANAGER_URL}/subscriptions/{scope.SubscriptionId}/resources?api-version=2021-04-01{GetFilter(tag)}";
        _ResourceGroupEndpoint = $"{RESOURCE_MANAGER_URL}/subscriptions/{scope.SubscriptionId}/resourcegroups?api-version=2021-04-01{GetFilter(tag)}";
        _SubscriptionEndpoint = $"{RESOURCE_MANAGER_URL}/subscriptions/{scope.SubscriptionId}?api-version=2022-12-01";
        SubscriptionId = scope.SubscriptionId;
        TenantId = scope.TenantId;
        RefreshToken(scope.TenantId);
    }

    /// <inheritdoc/>
    public string SubscriptionId { get; }

    /// <inheritdoc/>
    public string TenantId { get; }

    /// <inheritdoc/>
    public async Task<JObject[]> GetResourcesAsync()
    {
        return await ListAsync(TenantId, _ResourceEndpoint, ignoreNotFound: false);
    }

    /// <inheritdoc/>
    public async Task<JObject[]> GetResourceGroupsAsync()
    {
        return await ListAsync(TenantId, _ResourceGroupEndpoint, ignoreNotFound: false);
    }

    /// <inheritdoc/>
    public async Task<JObject> GetSubscriptionAsync()
    {
        return await GetAsync(TenantId, _SubscriptionEndpoint);
    }

    /// <inheritdoc/>
    public async Task<JObject> GetResourceAsync(string resourceId)
    {
        if (!TryGetLatestAPIVersion(ResourceHelper.GetResourceType(resourceId), out var apiVersion))
            return null;

        return await GetAsync(TenantId, $"{RESOURCE_MANAGER_URL}{resourceId}?api-version={apiVersion}");
    }

    private static string GetFilter(Hashtable tag)
    {
        if (tag == null || tag.Count == 0)
            return string.Empty;

        var first = true;
        var sb = new StringBuilder("&$filter=");
        foreach (DictionaryEntry kv in tag)
        {
            if (!first)
                sb.Append(" and ");

            sb.Append("tagName eq '");
            sb.Append(kv.Key);
            sb.Append("' and tagValue eq '");
            sb.Append(kv.Value);
            sb.Append("'");
            first = false;
        }
        return sb.ToString();
    }

    private bool TryGetLatestAPIVersion(string resourceType, out string apiVersion)
    {
        apiVersion = null;
        if (string.IsNullOrEmpty(resourceType))
            return false;

        _ProviderData ??= new ProviderData();
        if (!_ProviderData.TryResourceType(resourceType, out var data) ||
            data.ApiVersions == null ||
            data.ApiVersions.Length == 0)
            return false;

        apiVersion = data.ApiVersions[0];
        return true;
    }
}
