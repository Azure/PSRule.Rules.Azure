// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using System;

namespace PSRule.Rules.Azure.Pipeline;

/// <summary>
/// The details for a subscription to export.
/// </summary>
public sealed class ExportSubscriptionScope
{
    /// <summary>
    /// Create a scope structure containing details for the subscription to export.
    /// </summary>
    /// <param name="subscriptionId">The subscription Id for the subscription to export.</param>
    /// <param name="tenantId">The tenant Id associated to the subscription being exported.</param>
    public ExportSubscriptionScope(string subscriptionId, string tenantId)
    {
        if (string.IsNullOrEmpty(subscriptionId))
            throw new ArgumentOutOfRangeException(nameof(subscriptionId));

        if (string.IsNullOrEmpty(tenantId))
            throw new ArgumentOutOfRangeException(nameof(tenantId));

        SubscriptionId = subscriptionId;
        TenantId = tenantId;
    }

    /// <summary>
    /// The subscription Id for the subscription to export.
    /// This is a <seealso cref="System.Guid"/> identifier.
    /// </summary>
    public string SubscriptionId { get; }

    /// <summary>
    /// The tenant Id associated to the subscription being exported.
    /// This is a <seealso cref="System.Guid"/> identifier.
    /// </summary>
    public string TenantId { get; }
}
