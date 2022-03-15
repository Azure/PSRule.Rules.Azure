// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@description('The name of the SignalR Service.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

// An example SignalR Service
resource service 'Microsoft.SignalRService/signalR@2021-10-01' = {
  name: name
  location: location
  kind: 'SignalR'
  sku: {
    name: 'Standard_S1'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: true
    features: [
      {
        flag: 'ServiceMode'
        value: 'Serverless'
      }
    ]
  }
}
