// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@description('The name of the Web App.')
param name string

@description('The name of the App Services Plan.')
param planName string

@description('Tags to apply to the resource.')
param tags object

@description('The location resources will be deployed.')
param location string = resourceGroup().location

// An example App Services Plan
resource appPlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: planName
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
    capacity: 2
  }
}

// An example Web App
resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    serverFarmId: appPlan.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      remoteDebuggingEnabled: false
      http20Enabled: true
    }
  }
  tags: tags
}
