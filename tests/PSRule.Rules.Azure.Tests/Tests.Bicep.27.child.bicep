// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param skuName string = 'Standard_LRS'
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

var formattedAccessPolicies = [
  for accessPolicy in (accessPolicies ?? []): {
    objectId: accessPolicy.objectId
    tenantId: contains(accessPolicy, 'tenantId') ? accessPolicy.tenantId : tenant().tenantId
    permissions: {}
  }
]

var secretList = secrets.?secureList ?? []

resource storage 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: 'test'
  #disable-next-line no-loc-expr-outside-params
  location: resourceGroup().location
  sku: {
    name: skuName
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

resource kvSecret 'Microsoft.KeyVault/vaults/secrets@2023-07-01' = [
  for item in secretList: {
    name: item.name
    properties: {
      value: item.value
    }
  }
]

resource storageAccount_objectReplicationPolicy 'Microsoft.Storage/storageAccounts/objectReplicationPolicies@2022-09-01' = {
  name: 'default'
  parent: storage
  properties: {
    sourceAccount: 'sourceId'
    destinationAccount: 'destId'
    rules: [
      {
        ruleId: null
        sourceContainer: 'source'
        destinationContainer: 'dest'
        filters: null
      }
    ]
  }
}

resource storageAccount_objectReplicationPolicyItems 'Microsoft.Storage/storageAccounts/objectReplicationPolicies@2022-09-01' = [
  for (item, index) in [1]: {
    name: 'default${index}'
    parent: storage
    properties: {
      sourceAccount: 'sourceId'
      destinationAccount: 'destId'
      rules: [
        {
          ruleId: null
          sourceContainer: 'source'
          destinationContainer: 'dest'
          filters: null
        }
      ]
    }
  }
]

output policyId string = storageAccount_objectReplicationPolicy.properties.policyId
output ruleIds string[] = map(storageAccount_objectReplicationPolicy.properties.rules, rule => rule.ruleId)
output fromFor string = storageAccount_objectReplicationPolicyItems[0].properties.sourceAccount
