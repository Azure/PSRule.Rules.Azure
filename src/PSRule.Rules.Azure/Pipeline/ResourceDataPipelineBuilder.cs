// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections;
using PSRule.Rules.Azure.Configuration;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A builder to configure the pipeline to export Azure resource data.
/// </summary>
public interface IResourceDataPipelineBuilder : IExportDataPipelineBuilder
{
    /// <summary>
    /// Specifies any resource group filters to be used.
    /// </summary>
    /// <param name="resourceGroup">If any are specified, only these resource groups will be included in results.</param>
    void ResourceGroup(string[] resourceGroup);

    /// <summary>
    /// Specifies any subscriptions filters to be used.
    /// </summary>
    /// <param name="scope">If any are specified, only these subscriptions will be included in results.</param>
    void Subscription(ExportSubscriptionScope[] scope);

    /// <summary>
    /// Specifies additional tags to filter resources by.
    /// </summary>
    /// <param name="tag">A hashtable of tags to use for filtering resources.</param>
    void Tag(Hashtable tag);

    /// <summary>
    /// Specifies the path to write output.
    /// </summary>
    /// <param name="path">The directory path to write output.</param>
    void OutputPath(string path);

    /// <summary>
    /// Specifies the default tenant to use when the tenant is unknown.
    /// </summary>
    /// <param name="tenantId">The tenant Id of the default tenant.</param>
    void Tenant(string tenantId);
}

/// <summary>
/// A helper to build a pipeline that exports resource data from Azure.
/// </summary>
internal sealed class ResourceDataPipelineBuilder : ExportDataPipelineBuilder, IResourceDataPipelineBuilder
{
    private string[] _ResourceGroup;
    private ExportSubscriptionScope[] _Subscription;
    private Hashtable _Tag;
    private string _OutputPath;
    private string _TenantId;

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
    public void Tenant(string tenantId)
    {
        _TenantId = tenantId;
    }

    /// <inheritdoc/>
    public override IPipeline Build()
    {
        return new ResourceDataPipeline(PrepareContext(), _Subscription, _ResourceGroup, _AccessToken, _Tag, _RetryCount, _RetryInterval, _OutputPath, _TenantId);
    }
}
