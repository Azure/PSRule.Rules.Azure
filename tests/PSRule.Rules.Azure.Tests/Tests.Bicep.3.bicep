// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

resource storageaccount 'Microsoft.Storage/storageAccounts@2021-02-01' = {
  name: 'storage1'
  location: 'eastus'
  kind: 'StorageV2'
  sku: {
    name: 'Premium_LRS'
  }
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2021-08-01' = {
  name: '${storageaccount.name}/default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}

module pe_deploy 'Tests.Bicep.3.pe.bicep' = {
  name: 'pe_deploy'
  params: {
    storageAccountName: storageaccount.name
  }
}

module dns_deploy 'Tests.Bicep.3.dns.bicep' = {
  name: 'pe_dns_deploy'
  params: {
    storageAccountName: storageaccount.name
    nicId: pe_deploy.outputs.nicId
  }
}
