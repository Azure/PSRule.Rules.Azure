// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template;

/// <summary>
/// The ARM scope of the deployment.
/// </summary>
internal enum DeploymentScope
{
    ResourceGroup = 0,

    Subscription = 1,

    ManagementGroup = 2,

    Tenant = 3,
}
