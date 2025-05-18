// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

param location string = resourceGroup().location

@secure()
param secret string = newGuid()

resource vault 'Microsoft.KeyVault/vaults@2021-10-01' existing = {
  name: 'vault1'
}

resource kvSecret 'Microsoft.KeyVault/vaults/secrets@2021-10-01' = {
  parent: vault
  name: 'secret1'
  properties: {
    value: secret
  }
}

resource storage 'Microsoft.Storage/storageAccounts@2021-09-01' = {
  name: 'storage1'
  location: location
  sku: {
    name: 'Standard_LRS'
  }
  kind: 'StorageV2'
}

module child './Tests.Bicep.7.child.bicep' = {
  name: 'child'
  params: {
    secret: vault.getSecret('secret1')
  }
}

module good './Tests.Bicep.7.good.bicep' = {
  name: 'good'
}

output id string = kvSecret.id
output contentType string = kvSecret.properties.contentType

// Secret parameter assigned to output
output secret string = secret

// Secret from listLists assigned to output
output secretFromListKeys string = storage.listKeys().keys[0].value

// Secret from key vault reference assigned to output
output secretFromChild string = child.outputs.secretFromParameter

// Use a secure output
@secure()
output secureSecretFromChild string = child.outputs.secretFromParameter
