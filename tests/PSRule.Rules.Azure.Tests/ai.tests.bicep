// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

@description('The name of the resource.')
param name string = 'cognitive'

@description('The location resources will be deployed.')
param location string = resourceGroup().location

resource account01 'Microsoft.CognitiveServices/accounts@2022-03-01' = {
  name: '${name}-01'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'S0'
  }
  kind: 'CognitiveServices'
  properties: {
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
    }
    disableLocalAuth: true
  }
}

resource account02 'Microsoft.CognitiveServices/accounts@2022-03-01' = {
  name: '${name}-02'
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'TextAnalytics'
  properties: {}
}

resource account03 'Microsoft.CognitiveServices/accounts@2022-03-01' = {
  name: '${name}-03'
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'S0'
  }
  kind: 'TextAnalytics'
  properties: {
    networkAcls: {
      defaultAction: 'Deny'
    }
    disableLocalAuth: true
  }
}
