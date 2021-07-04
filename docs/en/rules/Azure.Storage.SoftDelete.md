---
severity: Important
pillar: Reliability
category: Data management
resource: Storage Account
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

## RECOMMENDATION

Consider enabling soft delete on storage accounts to protect blobs from accidental deletion or modification.

## EXAMPLES

### Configure with Azure template

```json
{
    "comments": "Storage Account",
    "type": "Microsoft.Storage/storageAccounts",
    "apiVersion": "2019-06-01",
    "name": "st0000001",
    "location": "eastus",
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

- [Soft delete for Azure Storage blobs](https://docs.microsoft.com/azure/storage/blobs/soft-delete-blob-overview)
- [RBAC operations for Storage](https://docs.microsoft.com/azure/role-based-access-control/resource-provider-operations#microsoftstorage)
- [Blob storage features available in Azure Data Lake Storage Gen2](https://docs.microsoft.com/azure/storage/blobs/data-lake-storage-supported-blob-storage-features)
- [Azure resource template](https://docs.microsoft.com/azure/templates/microsoft.storage/storageaccounts/blobservices)
