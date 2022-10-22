---
severity: Important
pillar: Reliability
category: Data management
resource: Storage Account
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
    "comments": "Storage Account",
    "type": "Microsoft.Storage/storageAccounts",
    "apiVersion": "2021-04-01",
    "name": "st0000001",
    "location": "[parameters('location')]",
    "sku": {
        "name": "Standard_GRS",
        "tier": "Standard"
    },
    "kind": "StorageV2",
    "properties": {
        "supportsHttpsTrafficOnly": true,
        "accessTier": "Hot",
        "allowBlobPublicAccess": false,
        "minimumTlsVersion": "TLS1_2"
    },
    "resources": [
        {
            "comments": "Configure blob storage services",
            "type": "Microsoft.Storage/storageAccounts/blobServices",
            "apiVersion": "2019-06-01",
            "name": "st0000001/default",
            "dependsOn": [
                "[resourceId('Microsoft.Storage/storageAccounts', 'st0000001')]"
            ],
            "sku": {
                "name": "Standard_GRS"
            },
            "properties": {
                "cors": {
                    "corsRules": []
                },
                "deleteRetentionPolicy": {
                    "enabled": true,
                    "days": 7
                },
                "containerDeleteRetentionPolicy": {
                    "enabled": true,
                    "days": 7
                }
            }
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
resource st0000001_blob 'Microsoft.Storage/storageAccounts/blobServices@2021-04-01' = {
  name: 'default'
  parent: st0000001
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

- [Soft delete for containers](https://learn.microsoft.com/azure/storage/blobs/soft-delete-container-overview)
- [Enable and manage soft delete for containers](https://learn.microsoft.com/azure/storage/blobs/soft-delete-container-enable?tabs=azure-portal)
- [RBAC operations for Storage](https://docs.microsoft.com/azure/role-based-access-control/resource-provider-operations#microsoftstorage)
- [Azure resource template](https://docs.microsoft.com/azure/templates/microsoft.storage/storageaccounts/blobservices)
