// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@minLength(3)
@maxLength(44)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

@description('The location of a secondary replica.')
param secondaryLocation string = location

// An example Cosmos DB account using the NoSQL API.
resource nosql 'Microsoft.DocumentDB/databaseAccounts@2025-04-15' = {
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
      {
        locationName: secondaryLocation
        failoverPriority: 1
        isZoneRedundant: false
      }
    ]
    disableKeyBasedMetadataWriteAccess: true
    minimalTlsVersion: 'Tls12'
  }
}

// An example No SQL API database in a Cosmos DB account.
resource database 'Microsoft.DocumentDB/databaseAccounts/sqlDatabases@2025-04-15' = {
  name: 'sql-001'
  parent: nosql
  properties: {
    resource: {
      id: 'sql-001'
    }
  }
}

// An example Cosmos DB account using the Gremlin API.
resource gremlin 'Microsoft.DocumentDB/databaseAccounts@2025-04-15' = {
  name: name
  location: location
  kind: 'GlobalDocumentDB'
  properties: {
    capabilities: [
      {
        name: 'EnableGremlin'
      }
    ]
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: true
      }
    ]
    databaseAccountOfferType: 'Standard'
    minimalTlsVersion: 'Tls12'
    backupPolicy: {
      type: 'Periodic'
      periodicModeProperties: {
        backupIntervalInMinutes: 240
        backupRetentionIntervalInHours: 8
        backupStorageRedundancy: 'Geo'
      }
    }
  }
  tags: {
    defaultExperience: 'Gremlin (graph)'
  }
}
