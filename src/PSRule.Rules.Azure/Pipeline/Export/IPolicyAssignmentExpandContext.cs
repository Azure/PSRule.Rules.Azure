// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Pipeline.Export;

#nullable enable

internal interface IPolicyAssignmentExpandContext : ILogger
{
    /// <summary>
    /// The tenant Id for the export context.
    /// </summary>
    string TenantId { get; }

    /// <summary>
    /// Get a resource.
    /// </summary>
    /// <param name="tenantId">The tenant Id for the request.</param>
    /// <param name="requestUri">The resource URI.</param>
    /// <param name="apiVersion">The apiVersion of the resource provider.</param>
    /// <param name="queryString">An optional query string that specifies additional arguments.</param>
    Task<JObject> GetAsync(string tenantId, string requestUri, string apiVersion, string? queryString);

    /// <summary>
    /// List resources.
    /// </summary>
    /// <param name="tenantId">The tenant Id for the request.</param>
    /// <param name="requestUri">The resource URI.</param>
    /// <param name="apiVersion">The apiVersion of the resource provider.</param>
    /// <param name="queryString">An optional query string that specifies additional arguments.</param>
    /// <param name="ignoreNotFound">Determines if not found status is ignored. Otherwise a warning is logged.</param>
    Task<JObject[]> ListAsync(string tenantId, string requestUri, string apiVersion, string? queryString, bool ignoreNotFound);
}

#nullable restore
