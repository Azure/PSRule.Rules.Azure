// Azure Storage Account

@metadata({
  description: 'The name of the Storage Account.'
  example: '<name>'
})
param storageAccountName string

@metadata({
  description: 'The Azure region to deploy to.'
  strongType: 'location'
  example: 'EastUS'
  ignore: true
})
param location string = resourceGroup().location

@allowed([
  'Standard_LRS'
  'Standard_GRS'
])
@description('Create the Storage Account as LRS or GRS.')
param sku string = 'Standard_LRS'

@minValue(0)
@maxValue(13)
@metadata({
  description: 'Determine how many additional characters are added to the storage account name as a suffix.'
  ignore: true
})
param suffixLength int = 0

@metadata({
  description: 'An array of storage containers to create on the storage account.'
  example: [
    {
      name: 'logs'
      publicAccess: 'None'
      metadata: {}
    }
  ]
})
param containers array = []

@metadata({
  description: 'An array of lifecycle management policies for the storage account.'
  example: {
    enabled: true
    name: '<rule_name>'
    type: 'Lifecycle'
    definition: {
      actions: {
        baseBlob: {
          delete: {
            daysAfterModificationGreaterThan: 7
          }
        }
      }
      filters: {
        blobTypes: [
          'blockBlob'
        ]
        prefixMatch: [
          'logs/'
        ]
      }
    }
  }
})
param lifecycleRules array = []

@minValue(0)
@maxValue(365)
@metadata({
  description: 'The number of days to retain deleted blobs. When set to 0, soft delete is disabled.'
  example: 7
})
param blobSoftDeleteDays int = 0

@minValue(0)
@maxValue(365)
@metadata({
  description: 'The number of days to retain deleted containers. When set to 0, soft delete is disabled.'
  example: 7
})
param containerSoftDeleteDays int = 0

@metadata({
  description: 'An array of file shares to create on the storage account.'
  example: [
    {
      name: '<share_name>'
      shareQuota: 5
      metadata: {}
    }
  ]
})
param shares array = []

@metadata({
  description: 'Determines if large file shares are enabled. This can not be disabled once enabled.'
  ignore: true
})
param useLargeFileShares bool = false

@minValue(0)
@maxValue(365)
@metadata({
  description: 'The number of days to retain deleted shares. When set to 0, soft delete is disabled.'
  example: 7
})
param shareSoftDeleteDays int = 0

@description('Determines if any containers can be configured with the anonymous access types of blob or container.')
param allowBlobPublicAccess bool = false

@metadata({
  description: 'Set to the objectId of Azure Key Vault to delegated permission for use with Key Managed Storage Accounts.'
  ignore: true
})
param keyVaultPrincipalId string = ''

@metadata({
  description: 'Tags to apply to the resource.'
  example: {
    service: '<service_name>'
    env: 'prod'
  }
})
param tags object

var normalName = concat(storageAccountName, ((suffixLength > 0) ? substring(uniqueString(resourceGroup().id), 0, suffixLength) : ''))

var blobSoftDeleteLookup = {
  'true': {
    enabled: true
    days: blobSoftDeleteDays
  }
  'false': {
    enabled: false
  }
}
var containerSoftDeleteLookup = {
  'true': {
    enabled: true
    days: containerSoftDeleteDays
  }
  'false': null
}
var shareSoftDeleteLookup = {
  'true': {
    enabled: true
    days: shareSoftDeleteDays
  }
  'false': {
    enabled: false
  }
}
var largeFileSharesState = (useLargeFileShares ? 'Enabled' : 'Disabled')
var storageAccountKeyOperatorRoleId = resourceId('Microsoft.Authorization/roleDefinitions', '81a9662b-bebf-436f-a333-f67b29880f12')

resource storageAccount 'Microsoft.Storage/storageAccounts@2019-06-01' = {
  name: normalName
  location: location
  sku: {
    name: sku
    tier: 'Standard'
  }
  kind: 'StorageV2'
  properties: {
    networkAcls: {
      bypass: 'AzureServices'
      virtualNetworkRules: []
      ipRules: []
      defaultAction: 'Allow'
    }
    supportsHttpsTrafficOnly: true
    encryption: {
      services: {
        file: {
          enabled: true
        }
        blob: {
          enabled: true
        }
      }
      keySource: 'Microsoft.Storage'
    }
    accessTier: 'Hot'
    largeFileSharesState: largeFileSharesState
    allowBlobPublicAccess: allowBlobPublicAccess
    minimumTlsVersion: 'TLS1_2'
  }
  tags: tags
}

resource blobServices 'Microsoft.Storage/storageAccounts/blobServices@2019-06-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    cors: {
      corsRules: []
    }
    deleteRetentionPolicy: blobSoftDeleteLookup[string((blobSoftDeleteDays > 0))]
    containerDeleteRetentionPolicy: containerSoftDeleteLookup[string((containerSoftDeleteDays > 0))]
  }
}

resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2019-06-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: shareSoftDeleteLookup[string((shareSoftDeleteDays > 0))]
  }
}

resource storageAccountContainers 'Microsoft.Storage/storageAccounts/blobServices/containers@2019-06-01' = [for i in range(0, ((length(containers) == 0) ? 1 : length(containers))): if (!(length(containers) == 0)) {
  name: ((length(containers) == 0) ? '${normalName}/default/empty' : '${normalName}/default/${containers[i].name}')
  properties: {
    metadata: containers[i].metadata
    publicAccess: containers[i].publicAccess
  }
  dependsOn: [
    blobServices
    storageAccount
  ]
}]

resource managementPolicies 'Microsoft.Storage/storageAccounts/managementPolicies@2019-06-01' = if (!empty(lifecycleRules)) {
  parent: storageAccount
  name: 'default'
  properties: {
    policy: {
      rules: lifecycleRules
    }
  }
}

resource storageAccountShares 'Microsoft.Storage/storageAccounts/fileServices/shares@2019-06-01' = [for i in range(0, ((length(shares) == 0) ? 1 : length(shares))): if (!(length(shares) == 0)) {
  name: ((length(shares) == 0) ? '${normalName}/default/empty' : '${normalName}/default/${shares[i].name}')
  properties: {
    metadata: shares[i].metadata
    shareQuota: shares[i].shareQuota
  }
  dependsOn: [
    fileServices
    storageAccount
  ]
}]

resource storageAccountKeyOperatorRole 'Microsoft.Storage/storageAccounts/providers/roleAssignments@2018-09-01-preview' = if (!empty(keyVaultPrincipalId)) {
  name: '${normalName}/Microsoft.Authorization/${guid(keyVaultPrincipalId, storageAccountKeyOperatorRoleId)}'
  properties: {
    roleDefinitionId: storageAccountKeyOperatorRoleId
    principalId: keyVaultPrincipalId
    scope: storageAccount.id
    principalType: 'ServicePrincipal'
  }
}

output storageAccountResourceId string = storageAccount.id
