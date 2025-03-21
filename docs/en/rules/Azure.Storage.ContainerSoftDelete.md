---
reviewed: 2023-09-02
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Storage Account
resourceType: Microsoft.Storage/storageAccounts,Microsoft.Storage/storageAccounts/blobServices
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.ContainerSoftDelete/
---

# Use container soft delete

## SYNOPSIS

Enable container soft delete on Storage Accounts.

## DESCRIPTION

Container soft delete protects your data from being accidentally or erroneously modified or deleted.
When container soft delete is enabled for a storage account, a container and its contents may be recovered
after it has been deleted, within a retention period that you specify.

Blob container soft delete should be considered part of the strategy to protect and retain data.
Also consider:

- Implementing role-based access control (RBAC).
- Configuring resource locks to protect against deletion.
- Configuring blob soft delete.

Blob containers can be configured to retain deleted containers for a period of time between 1 and 365 days.

## RECOMMENDATION

Consider enabling container soft delete on storage accounts to protect blob containers from accidental deletion or modification.

## EXAMPLES

### Configure with Azure template

To deploy Storage Accounts that pass this rule:

- Set the `properties.containerDeleteRetentionPolicy.enabled` property to `true` on the blob services sub-resource.
- Configure the `properties.containerDeleteRetentionPolicy.days` property to the number of days to retain blobs.

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

- Set the `properties.containerDeleteRetentionPolicy.enabled` property to `true` on the blob services sub-resource.
- Configure the `properties.containerDeleteRetentionPolicy.days` property to the number of days to retain blobs.

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

### Configure with Azure CLI

```bash
az storage account blob-service-properties update --enable-container-delete-retention true --container-delete-retention-days 7 -n '<name>' -g '<resource_group>'
```

### Configure with Azure PowerShell

```powershell
Enable-AzStorageContainerDeleteRetentionPolicy -ResourceGroupName '<resource_group>' -StorageAccountName '<name>' -RetentionDays 7
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
- [Soft delete for containers](https://learn.microsoft.com/azure/storage/blobs/soft-delete-container-overview)
- [Enable and manage soft delete for containers](https://learn.microsoft.com/azure/storage/blobs/soft-delete-container-enable)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts/blobservices)
