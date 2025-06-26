// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

targetScope = 'resourceGroup'

module cosmos 'br/public:avm/res/document-db/database-account:0.15.0' = {
  name: 'deploy-test-cosmosdb'
  params: {
    name: 'test-cosmosdb'
    location: 'eastus'
    mongodbDatabases: [
      {
        name: 'default'
        tag: 'default database'
      }
    ]
    enableTelemetry: false
    databaseAccountOfferType: 'Standard'
    automaticFailover: false
    serverVersion: '7.0'
    capabilitiesToAdd: [
      'EnableMongo'
    ]
    enableAnalyticalStorage: true
    defaultConsistencyLevel: 'Session'
    maxIntervalInSeconds: 5
    maxStalenessPrefix: 100
    zoneRedundant: false
  }
}

module appConfig 'br/public:avm/res/app-configuration/configuration-store:0.6.3' = {
  name: 'deploy-test-app-config'
  params: {
    name: 'test-app-config'
    location: 'eastus'
    enableTelemetry: false
    managedIdentities: { systemAssigned: true }
    sku: 'Standard'
    disableLocalAuth: false
    keyValues: [
      {
        name: 'CONNECTION'
        value: cosmos.outputs.primaryReadWriteConnectionString
      }
      {
        name: 'ENDPOINT'
        value: cosmos.outputs.endpoint
      }
    ]
  }
}
