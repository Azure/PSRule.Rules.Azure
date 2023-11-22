// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'managementGroup'

resource subscriptionAlias 'Microsoft.Subscription/aliases@2021-10-01' = {
  scope: tenant()
  name: 'sub1'
  properties: {
    workload: 'DevTest'
    displayName: 'sub1'
    billingScope: ' /billingAccounts/nn/enrollmentAccounts/nn'
  }
}

module rbac './Tests.Bicep.31.child.bicep' = {
  scope: subscription('00000000-0000-0000-0000-000000000000')
  name: 'rbac'
}
