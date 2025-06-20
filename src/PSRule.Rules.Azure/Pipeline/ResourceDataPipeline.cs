// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Management.Automation;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Arm;
using PSRule.Rules.Azure.Pipeline.Export;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A pipeline to export resource data from Azure.
/// </summary>
internal sealed class ResourceDataPipeline : ExportDataPipeline
{
    private const string PROPERTY_ID = "id";
    private const string PROPERTY_TYPE = "type";
    private const string PROPERTY_NAME = "name";
    private const string PROPERTY_SUBSCRIPTION_ID = "subscriptionId";
    private const string PROPERTY_DISPLAYNAME = "displayName";
    private const string PROPERTY_TENANT_ID = "tenantId";

    private const string PLACEHOLDER_SUBSCRIPTION_TYPE = "Microsoft.Subscription";

    private const string ERROR_ID_RESOURCE_DATA_EXPAND = "PSRule.Rules.Azure.ResourceDataExpand";

    private readonly ConcurrentQueue<JObject> _Resources;
    private readonly ConcurrentQueue<JObject> _Output;
    private readonly int _ExpandThreadCount;
    private readonly bool _SecurityAlerts;
    private readonly ExportSubscriptionScope[] _Subscription;
    private readonly HashSet<string> _ResourceGroup;
    private readonly Hashtable _Tag;
    private readonly int _RetryCount;
    private readonly int _RetryInterval;
    private readonly string _OutputPath;
    private readonly string _TenantId;

    public ResourceDataPipeline(PipelineContext context, ExportSubscriptionScope[] subscription, string[] resourceGroup, GetAccessTokenFn getToken, Hashtable tag, int retryCount, int retryInterval, string outputPath, string tenantId, bool securityAlerts)
        : base(context, getToken)
    {
        _Subscription = subscription;
        _ResourceGroup = resourceGroup != null && resourceGroup.Length > 0 ? new HashSet<string>(resourceGroup, StringComparer.OrdinalIgnoreCase) : null;
        _Tag = tag;
        _RetryCount = retryCount;
        _RetryInterval = retryInterval;
        _OutputPath = outputPath;
        _TenantId = tenantId;
        _Resources = new ConcurrentQueue<JObject>();
        _Output = new ConcurrentQueue<JObject>();
        _ExpandThreadCount = Environment.ProcessorCount > 0 ? Environment.ProcessorCount * 4 : 20;
        _SecurityAlerts = securityAlerts;
    }

    /// <inheritdoc/>
    public override void Begin()
    {
        // Process each subscription
        for (var i = 0; _Subscription != null && i < _Subscription.Length; i++)
            GetResourceBySubscription(_Subscription[i]);
    }

    /// <inheritdoc/>
    public override void Process(PSObject sourceObject)
    {
        if (sourceObject != null &&
            sourceObject.BaseObject is string resourceId &&
            !string.IsNullOrEmpty(resourceId))
            GetResourceById(resourceId);
    }

    /// <inheritdoc/>
    public override void End()
    {
        ExpandResource(_ExpandThreadCount);
        WriteOutput();
        base.End();
    }

    /// <summary>
    /// Write output to file or pipeline.
    /// </summary>
    private void WriteOutput()
    {
        var output = _Output.ToArray();
        if (_OutputPath == null)
        {
            // Pass through results to pipeline
            Context.Writer.WriteObject(JsonConvert.SerializeObject(output), enumerateCollection: false);
        }
        else
        {
            // Group results into subscriptions a write each to a new file.
            foreach (var group in output.GroupBy((r) => r[PROPERTY_SUBSCRIPTION_ID].Value<string>().ToLowerInvariant()))
            {
                var filePath = Path.Combine(_OutputPath, string.Concat(group.Key, ".json"));
                File.WriteAllText(filePath, JsonConvert.SerializeObject(group.ToArray()), Encoding.UTF8);
                Context.Writer.WriteObject(new FileInfo(filePath), enumerateCollection: false);
            }
        }
    }

    #region Get resources

    /// <summary>
    /// Get a resource for expansion by resource Id.
    /// </summary>
    /// <param name="resourceId">The specified resource Id.</param>
    private void GetResourceById(string resourceId)
    {
        if (!ResourceHelper.TrySubscriptionId(resourceId, out var subscriptionId))
            return;

        Context.Writer.VerboseGetResource(resourceId);
        var scope = new ExportSubscriptionScope(subscriptionId, _TenantId);
        var context = new SubscriptionExportContext(Context, scope, TokenCache, _Tag);

        // Get results from ARM
        GetResourceAsync(context, resourceId).Wait();
    }

    /// <summary>
    /// Get a specific resource by Id.
    /// </summary>
    private async Task<int> GetResourceAsync(ISubscriptionExportContext context, string resourceId)
    {
        var added = 0;
        var r = await context.GetResourceAsync(resourceId);
        if (r != null)
        {
            added++;
            r.Add(PROPERTY_TENANT_ID, context.TenantId);
            _Resources.Enqueue(r);
            added++;
        }
        return added;
    }

    /// <summary>
    /// Get resources, resource groups and the specified subscription within the subscription scope.
    /// Resources are then queued for expansion.
    /// </summary>
    /// <param name="scope">The subscription scope.</param>
    private void GetResourceBySubscription(ExportSubscriptionScope scope)
    {
        Context.Writer.VerboseGetResources(scope.SubscriptionId);
        var context = new SubscriptionExportContext(Context, scope, TokenCache, _Tag);
        var pool = new Task<int>[3];

        // Get results from ARM
        pool[0] = GetResourcesAsync(context);
        pool[1] = GetResourceGroupsAsync(context);
        pool[2] = GetSubscriptionAsync(context);

        Task.WaitAll(pool);
        var count = pool[0].Result + pool[1].Result + pool[2].Result;
        Context.Writer.VerboseGetResourcesResult(count, scope.SubscriptionId);
    }

    /// <summary>
    /// Get a subscription resource.
    /// </summary>
    private async Task<int> GetSubscriptionAsync(ISubscriptionExportContext context)
    {
        var added = 0;
        var r = await context.GetSubscriptionAsync();
        if (r != null)
        {
            r.Add(PROPERTY_TYPE, PLACEHOLDER_SUBSCRIPTION_TYPE);
            if (r.TryGetProperty(PROPERTY_DISPLAYNAME, out var displayName))
                r.Add(PROPERTY_NAME, displayName);

            _Resources.Enqueue(r);
            added++;
        }
        return added;
    }

    /// <summary>
    /// Get a list of resource groups for a subscription.
    /// </summary>
    private async Task<int> GetResourceGroupsAsync(ISubscriptionExportContext context)
    {
        var added = 0;
        foreach (var r in await context.GetResourceGroupsAsync())
        {
            // If resource group filtering is specified only queue resources in the specified resource group
            if (_ResourceGroup == null || (ResourceHelper.TryResourceGroup(r[PROPERTY_ID].Value<string>(), out _, out var resourceGroupName) &&
                _ResourceGroup.Contains(resourceGroupName)))
            {
                r.Add(PROPERTY_TENANT_ID, context.TenantId);
                _Resources.Enqueue(r);
                added++;
            }
        }
        return added;
    }

    /// <summary>
    /// Get a list of resources for a subscription.
    /// </summary>
    private async Task<int> GetResourcesAsync(ISubscriptionExportContext context)
    {
        var added = 0;
        foreach (var r in await context.GetResourcesAsync())
        {
            // If resource group filtering is specified only queue resources in the specified resource group
            if (_ResourceGroup == null || (ResourceHelper.TryResourceGroup(r[PROPERTY_ID].Value<string>(), out _, out var resourceGroupName) &&
                _ResourceGroup.Contains(resourceGroupName)))
            {
                r.Add(PROPERTY_TENANT_ID, context.TenantId);
                _Resources.Enqueue(r);
                added++;
            }
        }
        return added;
    }

    #endregion Get resources

    #region Expand resources

    /// <summary>
    /// Expand resources from the queue.
    /// </summary>
    /// <param name="poolSize">The size of the thread pool to use.</param>
    private void ExpandResource(int poolSize)
    {
        var context = new ResourceExportContext(Context, _Resources, TokenCache, _RetryCount, _RetryInterval, _SecurityAlerts);
        var visitor = new ResourceExportVisitor();
        var pool = new Task[poolSize];
        for (var i = 0; i < poolSize; i++)
        {
            pool[i] = Task.Run(async () =>
            {
                while (!_Resources.IsEmpty && _Resources.TryDequeue(out var r))
                {
                    context.VerboseExpandingResource(r[PROPERTY_ID].Value<string>());
                    try
                    {
                        await visitor.VisitAsync(context, r);
                        _Output.Enqueue(r);
                    }
                    catch (Exception ex)
                    {
                        context.Error(ex, ERROR_ID_RESOURCE_DATA_EXPAND);
                    }
                }
            });
        }
        context.Wait();
        Task.WaitAll(pool);
        context.Flush();
        pool.DisposeAll();
    }

    #endregion Expand resources
}
