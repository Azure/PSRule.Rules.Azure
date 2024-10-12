// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Pipeline.Export;

internal interface ISubscriptionExportContext
{
    /// <summary>
    /// Get resources from an Azure subscription.
    /// </summary>
    Task<JObject[]> GetResourcesAsync();

    /// <summary>
    /// Get resource groups from an Azure subscription.
    /// </summary>
    Task<JObject[]> GetResourceGroupsAsync();

    /// <summary>
    /// Get a resource for the Azure subscription.
    /// </summary>
    Task<JObject> GetSubscriptionAsync();

    /// <summary>
    /// Get a specified Azure resource from a subscription.
    /// </summary>
    Task<JObject> GetResourceAsync(string resourceId);

    /// <summary>
    /// The subscription Id of the context subscription.
    /// </summary>
    string SubscriptionId { get; }

    /// <summary>
    /// The tenant Id of the context tenant.
    /// </summary>
    string TenantId { get; }
}
