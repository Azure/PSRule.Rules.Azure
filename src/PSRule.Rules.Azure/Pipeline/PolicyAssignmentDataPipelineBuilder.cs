// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Pipeline;

#nullable enable

/// <summary>
/// A builder to create a pipeline that exports policy assignment data from Azure.
/// </summary>
internal sealed class PolicyAssignmentDataPipelineBuilder(PSRuleOption options) : ExportDataPipelineBuilder, IPolicyAssignmentDataPipelineBuilder
{
    private string[]? _AssignmentId;
    private string? _OutputPath;
    private string[]? _ScopeId;
    private bool _PassThru;
    private PSRuleOption _Options = options;

    public void AssignmentId(string[]? id)
    {
        if (id == null || id.Length == 0)
            return;

        _AssignmentId = id;
    }

    public void OutputPath(string? path)
    {
        if (string.IsNullOrEmpty(path))
            return;

        _OutputPath = path;
    }

    public void Scope(string[]? scopeId)
    {
        if (scopeId == null || scopeId.Length == 0)
            return;

        _ScopeId = scopeId;
    }

    /// <inheritdoc/>
    public void PassThru(bool passThru)
    {
        _PassThru = passThru;
    }

    /// <inheritdoc/>
    public override IPipeline Build()
    {
        return new PolicyAssignmentDataPipeline(
            PrepareContext(),
            GetTenantId() ?? throw new PolicyAssignmentDataPipelineException(PSRuleResources.PFA0002),
            _AccessToken,
            GetRetryCount(),
            GetRetryInterval(),
            _OutputPath,
            _AssignmentId,
            _ScopeId
        );
    }
}

#nullable restore
