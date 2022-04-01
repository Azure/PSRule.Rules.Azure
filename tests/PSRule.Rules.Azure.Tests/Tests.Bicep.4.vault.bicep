// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

resource vault 'Microsoft.KeyVault/vaults@2019-09-01' = {
  name: 'keyvault001'
  location: resourceGroup().location
  properties: {
    enabledForDeployment: true
    enabledForTemplateDeployment: true
    enabledForDiskEncryption: true
    tenantId: tenant().tenantId
    accessPolicies: []
    sku: {
      name: 'standard'
      family: 'A'
    }
  }
}

resource logs 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: vault
  name: 'service'
  properties: {
    logs: [
      {
        enabled: true
        category: 'AuditEvent'
      }
    ]
  }
}
