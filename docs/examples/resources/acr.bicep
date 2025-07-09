// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@minLength(5)
@maxLength(50)
@sys.description('The name of the resource.')
param name string

@sys.description('The location resources will be deployed.')
param location string = resourceGroup().location

@sys.description('The location of the container registry replica.')
param secondaryLocation string = location

// An example container registry deployed with Premium SKU.
resource registry 'Microsoft.ContainerRegistry/registries@2025-05-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Premium'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    adminUserEnabled: false
    anonymousPullEnabled: false
    publicNetworkAccess: 'Disabled'
    zoneRedundancy: 'Enabled'
    policies: {
      quarantinePolicy: {
        status: 'enabled'
      }
      retentionPolicy: {
        days: 30
        status: 'enabled'
      }
      softDeletePolicy: {
        retentionDays: 90
        status: 'enabled'
      }
      exportPolicy: {
        status: 'disabled'
      }
    }
  }
}

// An example of a container registry replica in a different location.
resource registryReplica 'Microsoft.ContainerRegistry/registries/replications@2025-04-01' = {
  parent: registry
  name: secondaryLocation
  location: secondaryLocation
  properties: {
    regionEndpointEnabled: true
    zoneRedundancy: 'Enabled'
  }
}
