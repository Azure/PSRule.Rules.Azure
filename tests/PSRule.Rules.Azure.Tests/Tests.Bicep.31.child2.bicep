// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'managementGroup'

resource subscriptionAlias 'Microsoft.Subscription/aliases@2021-10-01' = {
  scope: tenant()
  name: 'sub2'
  properties: {
    workload: 'DevTest'
    displayName: 'sub2'
    billingScope: '/billingAccounts/nn/enrollmentAccounts/nn'
  }
}

output subscriptionId string = subscriptionAlias.properties.subscriptionId
