---
reviewed: 2023-09-02
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Storage Account
resourceType: Microsoft.Storage/storageAccounts,Microsoft.Storage/storageAccounts/blobServices
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.SoftDelete/
ms-content-id: 9927b427-e694-4485-9abf-61545e63956e
---

# Use blob soft delete

## SYNOPSIS

Enable blob soft delete on Storage Accounts.

## DESCRIPTION

Soft delete provides an easy way to recover deleted or modified blob data stored within Storage Accounts.
When soft delete is enabled, deleted blobs are kept and can be restored within the configured interval.

Blob soft delete should be considered part of the strategy to protect and retain data.
Also consider:

- Implementing role-based access control (RBAC).
- Configuring resource locks to protect against deletion.
- Configuring blob container soft delete.

Blobs can be configured to retain deleted blobs for a period of time between 1 and 365 days.

## RECOMMENDATION

Consider enabling soft delete on storage accounts to protect blobs from accidental deletion or modification.

## EXAMPLES

### Configure with Azure template

To deploy Storage Accounts that pass this rule:

- Set the `properties.deleteRetentionPolicy.enabled` property to `true` on the blob services sub-resource.
- Configure the `properties.deleteRetentionPolicy.days` property to the number of days to retain blobs.

```json
{
  "type": "Microsoft.Storage/storageAccounts",
  "apiVersion": "2023-01-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard_GRS"
  },
  "kind": "StorageV2",
  "properties": {
    "allowBlobPublicAccess": false,
    "supportsHttpsTrafficOnly": true,
    "minimumTlsVersion": "TLS1_2",
    "accessTier": "Hot",
    "allowSharedKeyAccess": false,
    "networkAcls": {
      "defaultAction": "Deny"
    }
  },
  "resources": [
    {
      "type": "Microsoft.Storage/storageAccounts/blobServices",
      "apiVersion": "2023-01-01",
      "name": "[format('{0}/{1}', parameters('name'), 'default')]",
      "properties": {
        "deleteRetentionPolicy": {
          "enabled": true,
          "days": 7
        },
        "containerDeleteRetentionPolicy": {
          "enabled": true,
          "days": 7
        }
      },
      "dependsOn": [
        "[resourceId('Microsoft.Storage/storageAccounts', parameters('name'))]"
      ]
    }
  ]
}
```

### Configure with Bicep

To deploy Storage Accounts that pass this rule:

- Set the `properties.deleteRetentionPolicy.enabled` property to `true` on the blob services sub-resource.
- Configure the `properties.deleteRetentionPolicy.days` property to the number of days to retain blobs.

For example:

```bicep
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    accessTier: 'Hot'
    allowSharedKeyAccess: false
    networkAcls: {
      defaultAction: 'Deny'
    }
  }
}

resource blobService 'Microsoft.Storage/storageAccounts/blobServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    deleteRetentionPolicy: {
      enabled: true
      days: 7
    }
    containerDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}
```

<!-- external:avm avm/res/storage/storage-account blobServices -->

### Configure with Azure CLI

```bash
az storage account blob-service-properties update --enable-delete-retention true --delete-retention-days 7 -n '<name>' -g '<resource_group>'
```

### Configure with Azure PowerShell

```powershell
Enable-AzStorageBlobDeleteRetentionPolicy -ResourceGroupName '<resource_group>' -AccountName '<name>' -RetentionDays 7
```

## NOTES

Cloud Shell storage with the tag `ms-resource-usage = 'azure-cloud-shell'` is excluded.
Storage accounts used for Cloud Shell are not intended to store data.

Storage accounts with:

- Hierarchical namespace enabled to not support blob soft delete.
- Deployed as a `FileStorage` storage account do not support blob soft delete.

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Storage Accounts and reliability](https://learn.microsoft.com/azure/well-architected/services/storage/storage-accounts/reliability)
- [Soft delete for Azure Storage blobs](https://learn.microsoft.com/azure/storage/blobs/soft-delete-blob-overview)
- [Blob storage features available in Azure Data Lake Storage Gen2](https://learn.microsoft.com/azure/storage/blobs/storage-feature-support-in-storage-accounts)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts/blobservices)
