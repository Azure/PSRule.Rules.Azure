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
