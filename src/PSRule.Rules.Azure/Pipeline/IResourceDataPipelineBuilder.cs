// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System.Collections;

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
