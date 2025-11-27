// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@minLength(1)
@maxLength(63)
@sys.description('The name of the resource.')
param name string

@sys.description('The location resources will be deployed.')
param location string = resourceGroup().location

@sys.description('The location of a secondary replica.')
param secondaryLocation string = location

// An example Azure Managed Redis instance with availability zones.
resource primary 'Microsoft.Cache/redisEnterprise@2025-07-01' = {
  name: name
  location: location
  properties: {
    highAvailability: 'Enabled'
    publicNetworkAccess: 'Disabled'
  }
  sku: {
    name: 'Balanced_B10'
  }
}

// An example secondary replica in an alternative region.
resource secondary 'Microsoft.Cache/redisEnterprise@2025-07-01' = {
  name: name
  location: secondaryLocation
  properties: {
    highAvailability: 'Enabled'
    publicNetworkAccess: 'Disabled'
  }
  sku: {
    name: 'Balanced_B10'
  }
}

// An example database replicated across the primary and secondary instances.
resource database 'Microsoft.Cache/redisEnterprise/databases@2025-07-01' = {
  parent: primary
  name: 'default'
  properties: {
    clientProtocol: 'Encrypted'
    evictionPolicy: 'VolatileLRU'
    clusteringPolicy: 'OSSCluster'
    deferUpgrade: 'NotDeferred'
    modules: [
      {
        name: 'RedisJSON'
      }
    ]
    persistence: {
      aofEnabled: false
      rdbEnabled: true
      rdbFrequency: '12h'
    }
    accessKeysAuthentication: 'Disabled'
    geoReplication: {
      groupNickname: 'group'
      linkedDatabases: [
        {
          id: resourceId('Microsoft.Cache/redisEnterprise/databases', secondary.name, 'default')
        }
      ]
    }
  }
}
