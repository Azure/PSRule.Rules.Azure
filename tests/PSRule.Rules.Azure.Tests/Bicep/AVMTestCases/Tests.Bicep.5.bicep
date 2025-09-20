// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/3521
// Contributed by @ThijmenDam

targetScope = 'subscription'

module functionApp 'br/public:avm/res/web/site:0.19.3' = {
  scope: resourceGroup('rg-test')
  params: {
    name: 'test-app'
    serverFarmResourceId: appServicePlan.outputs.resourceId
    kind: 'functionapp'
    siteConfig: {
      remoteDebuggingEnabled: false
    }
  }
}

module appServicePlan 'br/public:avm/res/web/serverfarm:0.5.0' = {
  scope: resourceGroup('rg-test')
  params: {
    name: 'test-plan'
    location: 'eastus'
    kind: 'functionapp'
    skuName: 'Y1'
  }
}
