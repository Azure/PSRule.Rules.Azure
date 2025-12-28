// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@minLength(1)
@maxLength(63)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

param login string
param sid string

// An example SQL managed instance.
resource managedInstance 'Microsoft.Sql/managedInstances@2023-08-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'GP_Gen5'
  }
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: login
      sid: sid
      principalType: 'Group'
      tenantId: tenant().tenantId
    }
    maintenanceConfigurationId: maintenanceWindow.id
  }
}

resource maintenanceWindow 'Microsoft.Maintenance/publicMaintenanceConfigurations@2023-04-01' existing = {
  scope: subscription()
  name: 'SQL_WestEurope_MI_1'
}
