// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Configuration;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// A helper for building a template expansion pipeline.
/// </summary>
public interface ITemplatePipelineBuilder : IPipelineBuilder
{
    /// <summary>
    /// Configures the name of the deployment.
    /// </summary>
    void Deployment(string deploymentName);

    /// <summary>
    /// Configures properties of the resource group.
    /// </summary>
    void ResourceGroup(ResourceGroupOption resourceGroup);

    /// <summary>
    /// Configures properties of the subscription.
    /// </summary>
    void Subscription(SubscriptionOption subscription);

    /// <summary>
    /// Determines if expanded resources are passed through to the pipeline.
    /// </summary>
    void PassThru(bool passThru);
}
