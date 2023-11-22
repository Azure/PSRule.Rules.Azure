// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

namespace PSRule.Rules.Azure.Data.Template
{
    internal enum DeploymentScope
    {
        ResourceGroup = 0,

        Subscription = 1,

        ManagementGroup = 2,

        Tenant = 3,
    }
}
