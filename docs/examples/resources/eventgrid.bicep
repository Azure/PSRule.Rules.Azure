// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@minLength(3)
@maxLength(50)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

@description('The resource ID of the storage account.')
param storageId string

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

// An example of an Event Grid System Topic.
resource systemTopic 'Microsoft.EventGrid/systemTopics@2025-02-15' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    source: storageId
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}

// An example of an Event Grid Namespace with public access disabled, and zone redundancy enabled.
resource namespace 'Microsoft.EventGrid/namespaces@2025-02-15' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    minimumTlsVersionAllowed: '1.2'
    isZoneRedundant: true
  }
}
