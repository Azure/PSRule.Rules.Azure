// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@description('The name of the Event Grid Topic.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

// An example Event Grid Topic with local auth and public access disabled.
resource topic 'Microsoft.EventGrid/topics@2025-02-15' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: true
    publicNetworkAccess: 'Disabled'
    minimumTlsVersionAllowed: '1.2'
    inputSchema: 'CloudEventSchemaV1_0'
  }
}

// An example Event Grid Domain with local auth and public access disabled.
resource domain 'Microsoft.EventGrid/domains@2025-02-15' = {
  name: name
  location: location
  properties: {
    disableLocalAuth: true
    publicNetworkAccess: 'Disabled'
    minimumTlsVersionAllowed: '1.2'
    inputSchema: 'CloudEventSchemaV1_0'
  }
}
