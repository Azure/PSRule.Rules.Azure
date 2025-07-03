// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;
using System.Collections.Concurrent;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Text;
using System.Threading.Tasks;
using Newtonsoft.Json;
using Newtonsoft.Json.Linq;
using PSRule.Rules.Azure.Pipeline.Export;

namespace PSRule.Rules.Azure.Pipeline;

#nullable enable

/// <summary>
/// A pipeline to export policy assignments, and associated definitions and exemptions from Azure.
/// </summary>
internal class PolicyAssignmentDataPipeline(PipelineContext context, string tenantId, GetAccessTokenFn accessToken, int retryCount, int retryInterval, string outputPath, string[]? assignmentId, string[]? scopeId)
    : ExportDataPipeline(context, tenantId, accessToken, retryCount, retryInterval, outputPath)
{
    private const string PROPERTY_ID = "id";
    private const string PROPERTY_PROPERTIES = "properties";
    private const string PROPERTY_SCOPE = "scope";

    private const string ERROR_ID_RESOURCE_DATA_EXPAND = "PSRule.Rules.Azure.ResourceDataExpand";

    private readonly string[]? _AssignmentId = assignmentId;
    private readonly string[]? _ScopeId = scopeId;

    private readonly ConcurrentQueue<JObject> _Resources = new();
    private readonly ConcurrentQueue<JObject> _Output = new();

    /// <inheritdoc/>
    public override void Begin()
    {
        Context.Writer.VerboseUsingTenantId(TenantId);

        // Process each assignment ID.
        if (_AssignmentId != null && _AssignmentId.Length > 0)
            GetAssignmentById(_AssignmentId);

        // Process each scope.
        for (var i = 0; _ScopeId != null && i < _ScopeId.Length; i++)
            GetAssignmentByScope(_ScopeId[i]);
    }

    /// <inheritdoc/>
    public override void End()
    {
        ExpandPolicyAssignments(PoolSize);
        WriteOutput();
        base.End();
    }

    /// <summary>
    /// Write output to file or pipeline.
    /// </summary>
    private void WriteOutput()
    {
        if (_Output == null || _Output.IsEmpty)
            return;

        var output = _Output.ToArray();
        using var generator = new PolicyAssignmentDataOutputPathGenerator();
        if (OutputPath == null)
        {
            // Pass through results to pipeline
            Context.Writer.WriteObject(JsonConvert.SerializeObject(output), enumerateCollection: false);
        }
        else
        {
            // Group assignment scopes.
            foreach (var group in output.GroupBy((r) => r[PROPERTY_PROPERTIES]?[PROPERTY_SCOPE]?.Value<string>()?.ToLowerInvariant()))
            {
                if (string.IsNullOrEmpty(group.Key))
                {
                    Context.Writer.WriteWarning("Bad assignment scope.");
                    continue;
                }

                var filePath = generator.GenerateOutputPath(OutputPath, group.Key);
                File.WriteAllText(filePath, JsonConvert.SerializeObject(group.ToArray()), Encoding.UTF8);
                Context.Writer.WriteObject(new FileInfo(filePath), enumerateCollection: false);
            }
        }
    }

    #region Get resources

    private void GetAssignmentByScope(string scopeId)
    {
        if (string.IsNullOrWhiteSpace(scopeId))
            return;

        Context.Writer.VerboseGetAssignmentByScope(scopeId);

        var export = new PolicyAssignmentScopedExportContext(Context, TokenCache, RetryCount, RetryInterval, TenantId, scopeId);
        var resourcesTask = GetAssignmentsAsync(export);
        resourcesTask.Wait();

        var count = resourcesTask.Result;
        Context.Writer.VerboseGetAssignmentByScopeResult(count, scopeId);
    }

    private void GetAssignmentById(string[] assignmentId)
    {
        if (assignmentId == null || assignmentId.Length == 0)
            return;

        var export = new PolicyAssignmentScopedExportContext(Context, TokenCache, RetryCount, RetryInterval, TenantId, string.Empty);
        var tasks = new List<Task<JObject>>();

        for (var i = 0; i < assignmentId.Length; i++)
        {
            if (string.IsNullOrWhiteSpace(assignmentId[i]))
                continue;

            Context.Writer.VerboseGetAssignmentById(assignmentId[i]);

            var resource = export.GetResourceAsync(assignmentId[i]);
            tasks.Add(resource);
        }

        Task.WaitAll([.. tasks]);

        var count = 0;
        foreach (var task in tasks)
        {
            if (task.IsCompleted && task.Result != null)
            {
                _Resources.Enqueue(task.Result);
                count++;
            }
        }

        Context.Writer.VerboseGetAssignmentByIdResult(count);
    }

    private async Task<int> GetAssignmentsAsync(PolicyAssignmentScopedExportContext context)
    {
        var added = 0;
        foreach (var r in await context.GetResourcesAsync())
        {
            _Resources.Enqueue(r);
            added++;
        }
        return added;
    }

    #endregion Get resources

    #region Expand resources

    /// <summary>
    /// Expand policy assignments from the queue.
    /// </summary>
    /// <param name="poolSize">The size of the thread pool to use.</param>
    private void ExpandPolicyAssignments(int poolSize)
    {
        Context.Writer.VerboseExpandingPolicyAssignments(poolSize);
        var context = new PolicyAssignmentExpandContext(Context, _Resources, TokenCache, RetryCount, RetryInterval, TenantId);
        var visitor = new PolicyAssignmentExpandVisitor();
        var pool = new Task[poolSize];
        for (var i = 0; i < poolSize; i++)
        {
            pool[i] = Task.Run(async () =>
            {
                while (!_Resources.IsEmpty && _Resources.TryDequeue(out var r))
                {
                    var id = r[PROPERTY_ID]?.Value<string>();
                    if (string.IsNullOrEmpty(id))
                        continue;

                    context.VerboseExpandingResource(id);
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

#nullable restore
