// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Threading.Tasks;
using Newtonsoft.Json.Linq;

namespace PSRule.Rules.Azure.Pipeline.Export;

internal interface IResourceExportContext : ILogger
{
    /// <summary>
    /// Determines if security alerts are included in the export.
    /// </summary>
    bool SecurityAlerts { get; }

    /// <summary>
    /// Get a resource.
    /// </summary>
    /// <param name="tenantId">The tenant Id for the request.</param>
    /// <param name="requestUri">The resource URI.</param>
    /// <param name="apiVersion">The apiVersion of the resource provider.</param>
    Task<JObject> GetAsync(string tenantId, string requestUri, string apiVersion);

    /// <summary>
    /// List resources.
    /// </summary>
    /// <param name="tenantId">The tenant Id for the request.</param>
    /// <param name="requestUri">The resource URI.</param>
    /// <param name="apiVersion">The apiVersion of the resource provider.</param>
    /// <param name="ignoreNotFound">Determines if not found status is ignored. Otherwise a warning is logged.</param>
    Task<JObject[]> ListAsync(string tenantId, string requestUri, string apiVersion, bool ignoreNotFound);
}
