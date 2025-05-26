// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@minLength(4)
@maxLength(63)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

param secondaryLocation string

// An example Log Analytics workspace with replication enabled.
resource workspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: name
  location: location
  properties: {
    replication: {
      enabled: true
      location: secondaryLocation
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: 30
    features: {
      disableLocalAuth: true
    }
    sku: {
      name: 'PerGB2018'
    }
  }
}
