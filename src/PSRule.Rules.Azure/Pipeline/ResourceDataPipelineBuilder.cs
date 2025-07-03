// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections;
using PSRule.Rules.Azure.Configuration;
using PSRule.Rules.Azure.Resources;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A helper to build a pipeline that exports resource data from Azure.
/// </summary>
internal sealed class ResourceDataPipelineBuilder : ExportDataPipelineBuilder, IResourceDataPipelineBuilder
{
    private string[] _ResourceGroup;
    private ExportSubscriptionScope[] _Subscription;
    private Hashtable _Tag;
    private string _OutputPath;
    private bool _SecurityAlerts;

    internal ResourceDataPipelineBuilder(PSRuleOption option)
        : base()
    {
        Configure(option);
    }

    /// <inheritdoc/>
    public void ResourceGroup(string[] resourceGroup)
    {
        if (resourceGroup == null || resourceGroup.Length == 0)
            return;

        _ResourceGroup = resourceGroup;
    }

    /// <inheritdoc/>
    public void Subscription(ExportSubscriptionScope[] scope)
    {
        if (scope == null || scope.Length == 0)
            return;

        _Subscription = scope;
    }

    /// <inheritdoc/>
    public void Tag(Hashtable tag)
    {
        if (tag == null || tag.Count == 0)
            return;

        _Tag = tag;
    }

    /// <inheritdoc/>
    public void OutputPath(string path)
    {
        _OutputPath = path;
    }

    /// <inheritdoc/>
    public void SecurityAlerts()
    {
        _SecurityAlerts = true;
    }

    /// <inheritdoc/>
    public override IPipeline Build()
    {
        return new ResourceDataPipeline(
            PrepareContext(),
            _Subscription,
            _ResourceGroup,
            _AccessToken,
            _Tag,
            GetRetryCount(),
            GetRetryInterval(),
            _OutputPath,
            GetTenantId() ?? throw new ResourceDataPipelineException(PSRuleResources.PFA0002),
            _SecurityAlerts
        );
    }
}
