// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

@description('The secondary location for geo-replication.')
param secondaryLocation string

// An example Service Bus namespace.
resource ns 'Microsoft.ServiceBus/namespaces@2025-05-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    disableLocalAuth: true
    minimumTlsVersion: '1.2'
    geoDataReplication: {
      maxReplicationLagDurationInSeconds: 300
      locations: [
        {
          locationName: location
          roleType: 'Primary'
        }
        {
          locationName: secondaryLocation
          roleType: 'Secondary'
        }
      ]
    }
  }
}

// An example Service Bus namespace with geo-replication enabled.
resource withReplication 'Microsoft.ServiceBus/namespaces@2025-05-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Premium'
  }
  properties: {
    disableLocalAuth: true
    minimumTlsVersion: '1.2'
    geoDataReplication: {
      maxReplicationLagDurationInSeconds: 300
      locations: [
        {
          locationName: location
          roleType: 'Primary'
        }
        {
          locationName: secondaryLocation
          roleType: 'Secondary'
        }
      ]
    }
  }
}
