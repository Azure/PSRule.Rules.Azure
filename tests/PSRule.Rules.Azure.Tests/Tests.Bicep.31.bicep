// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'managementGroup'

resource subscriptionAlias 'Microsoft.Subscription/aliases@2021-10-01' = {
  scope: tenant()
  name: 'sub1'
  properties: {
    workload: 'DevTest'
    displayName: 'sub1'
    billingScope: '/billingAccounts/nn/enrollmentAccounts/nn'
  }
}

module rbac './Tests.Bicep.31.child.bicep' = {
  scope: subscription('00000000-0000-0000-0000-000000000000')
  name: 'child'
}

module createSubscription './Tests.Bicep.31.child2.bicep' = {
  name: 'child2'
  scope: managementGroup()
}

module createSubscriptionResources './Tests.Bicep.31.child3.bicep' = {
  name: 'child3'
  params: {
    subscriptionId: createSubscription.outputs.subscriptionId
  }
}
