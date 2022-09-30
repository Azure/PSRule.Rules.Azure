// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@description('The name of the App Configuration Store.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

param locationsec string = 'northeurope' 

param repname string = 'replica01'

@description('The resource id of the Log Analytics workspace to send diagnostic logs to.')
param workspaceId string

// An example App Configuration Store
resource store 'Microsoft.AppConfiguration/configurationStores@2022-05-01' = {
  name: name
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    disableLocalAuth: true
    enablePurgeProtection: true
  }
}

resource replica 'Microsoft.AppConfiguration/configurationStores/replicas@2022-03-01-preview' = {
  name: repname
  location: locationsec
  parent: store

}

resource diagnostic 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: '${name}-diagnostic'
  scope: store
  properties: {
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          days: 90
          enabled: true
        }
      }
    ]
    workspaceId: workspaceId
  }
}
