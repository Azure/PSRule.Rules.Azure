// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param location string = resourceGroup().location

module storage './Tests.Bicep.8.storage.bicep' = {
  name: 'storage'
  params: {
    location: location
    sku: 'Standard_GRS'
    publicAccess: true
  }
}

module storage2 './Tests.Bicep.8.storage.bicep' = {
  name: 'storage2'
  params: {
    location: location
    tlsVersion: 'TLS1_0'
  }
  dependsOn: [
    storage
  ]
}

module blob 'Tests.Bicep.8.blob.bicep' = {
  name: 'blobServices'
  dependsOn: [
    storage
  ]
}

module blob2 'Tests.Bicep.8.blob.bicep' = {
  name: 'blobServices2'
  params: {
    deleteRetentionPolicy: false
  }
  dependsOn: [
    storage
  ]
}

resource web 'Microsoft.Web/sites@2022-03-01' = {
  name: 'app1'
  location: location
  properties: {
    siteConfig: {
      minTlsVersion: '1.2'
    }
  }
}

resource webConfig 'Microsoft.Web/sites/config@2022-03-01' = {
  parent: web
  name: 'web'
  properties: {
    minTlsVersion: '1.0'
  }
}

resource sql 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: 'sql-server'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
}

resource sqlAdmins 'Microsoft.Sql/servers/administrators@2022-02-01-preview' = {
  parent: sql
  name: 'ActiveDirectory'
  properties: {
    login: 'abc'
    administratorType: 'ActiveDirectory'
    sid: '00000000-0000-0000-0000-000000000000'
  }
}

module servicebus './Tests.Bicep.8.sb.bicep' = [for item in [ 'd1', 'd2' ]: {
  name: item
  params: {
    location: location
    iteration: item
  }
}]
