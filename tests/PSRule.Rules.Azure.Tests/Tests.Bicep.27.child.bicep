// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param minTLSVersion string?
param corsRules corsRule

type corsRule = {
  allowedHeaders: string[]
  allowedMethods: string[]
  allowedOrigins: string[]
  exposedHeaders: string[]
  maxAgeInSeconds: int
}[]?

param accessPolicies array?

@secure()
param secrets object?

var formattedAccessPolicies = [for accessPolicy in (accessPolicies ?? []): {
  objectId: accessPolicy.objectId
  tenantId: contains(accessPolicy, 'tenantId') ? accessPolicy.tenantId : tenant().tenantId
  permissions: {}
}]

var secretList = secrets.?secureList ?? []

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'test'
  #disable-next-line no-loc-expr-outside-params
  location: resourceGroup().location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
  properties: {
    minimumTlsVersion: minTLSVersion ?? 'TLS1_2'
  }

  resource blob 'blobServices' = {
    name: 'default'
    properties: {
      cors: {
        corsRules: corsRules ?? []
      }
    }
  }
}

resource kv 'Microsoft.KeyVault/vaults@2023-07-01' = {
  name: 'keyVault'
  #disable-next-line no-loc-expr-outside-params
  location: resourceGroup().location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenant().tenantId
    accessPolicies: formattedAccessPolicies
  }
}

resource kvSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = [for item in secretList: {
  name: item.name
  properties: {
    value: item.value
  }
}]
