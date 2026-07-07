// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Test case for https://github.com/Azure/PSRule.Rules.Azure/issues/2159

param vnetRgName string = 'rg-network'
param vnetName string = 'vnet-issue-2159'
param subnetName string = 'app'

resource vnet 'Microsoft.Network/virtualNetworks@2023-02-01' existing = {
  scope: resourceGroup(vnetRgName)
  name: vnetName
}

resource plan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: 'plan-issue-2159'
  location: resourceGroup().location
  sku: {
    name: 'Y1'
    tier: 'Dynamic'
  }
}

resource functionApp 'Microsoft.Web/sites@2022-09-01' = {
  name: 'func-issue-2159'
  location: resourceGroup().location
  kind: 'functionapp'
  properties: {
    serverFarmId: plan.id
    virtualNetworkSubnetId: filter(vnet.properties.subnets, s => s.name == subnetName)[0].id
    siteConfig: {}
  }
}
