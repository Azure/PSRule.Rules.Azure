// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@minLength(3)
@maxLength(44)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

// An example Cosmos DB account using the NoSQL API.
resource account 'Microsoft.DocumentDB/databaseAccounts@2025-04-15' = {
  name: name
  location: location
  properties: {
    enableFreeTier: false
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: true
      }
    ]
    disableKeyBasedMetadataWriteAccess: true
    minimalTlsVersion: 'Tls12'
  }
}

// An example No SQL API database in a Cosmos DB account.
resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2025-04-15' = {
  name: 'sql-001'
  parent: account
  properties: {
    resource: {
      id: 'sql-001'
    }
  }
}
