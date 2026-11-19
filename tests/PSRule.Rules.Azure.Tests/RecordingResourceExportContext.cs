// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Generic;
using System.Management.Automation;
using System.Threading.Tasks;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Pipeline.Export;

namespace PSRule.Rules.Azure;

#nullable enable

/// <summary>
/// An export context that records requests instead of calling Azure.
/// </summary>
internal sealed class RecordingResourceExportContext : IResourceExportContext
{
    private const string TENANT_ID = "ffffffff-ffff-ffff-ffff-ffffffffffff";

    public bool SecurityAlerts => false;

    public string TenantId => TENANT_ID;

    public List<(string RequestUri, string ApiVersion, bool IgnoreNotFound)> ListRequests { get; } = [];

    public Task<JObject> GetAsync(string tenantId, string requestUri, string apiVersion, string? queryString)
    {
        return Task.FromResult<JObject>(null!);
    }

    public Task<JObject[]> ListAsync(string tenantId, string requestUri, string apiVersion, string? queryString, bool ignoreNotFound)
    {
        ListRequests.Add((requestUri, apiVersion, ignoreNotFound));
        return Task.FromResult<JObject[]>([]);
    }

    public void WriteVerbose(string message) { }

    public void WriteVerbose(string format, params object[] args) { }

    public void WriteWarning(string message) { }

    public void WriteWarning(string format, params object[] args) { }

    public void WriteError(Exception exception, string errorId, ErrorCategory errorCategory, object targetObject) { }
}

#nullable restore
