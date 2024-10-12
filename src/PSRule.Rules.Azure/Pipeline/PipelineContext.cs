// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

using PSRule.Rules.Azure.Configuration;

namespace PSRule.Rules.Azure.Pipeline;

internal sealed class PipelineContext
{
    internal PipelineContext(PSRuleOption option, PipelineWriter writer)
    {
        Option = option;
        Writer = writer;

        var tenantId = Option.Configuration.Tenant?.TenantId ?? Option.Configuration.Subscription?.TenantId ?? TenantOption.Default.TenantId;
        Option.Configuration.ResourceGroup = ResourceGroupOption.Combine(Option.Configuration.ResourceGroup, ResourceGroupOption.Default);
        Option.Configuration.Tenant = TenantOption.Combine(Option.Configuration.Tenant, TenantOption.Default);
        Option.Configuration.Tenant.TenantId = tenantId;
        Option.Configuration.ManagementGroup = ManagementGroupOption.Combine(Option.Configuration.ManagementGroup, ManagementGroupOption.Default);
        Option.Configuration.Subscription = SubscriptionOption.Combine(Option.Configuration.Subscription, SubscriptionOption.Default);
        Option.Configuration.Subscription.TenantId = Option.Configuration.Tenant.TenantId;
        Option.Configuration.ResourceGroup.SubscriptionId = Option.Configuration.Subscription.SubscriptionId;
        Option.Configuration.ManagementGroup.Properties.TenantId = Option.Configuration.Tenant.TenantId;
    }

    public PSRuleOption Option { get; }

    public PipelineWriter Writer { get; }
}
