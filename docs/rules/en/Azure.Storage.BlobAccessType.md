---
severity: Important
pillar: Security
category: Identity and access management
resource: Storage Account
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Storage.BlobAccessType.md
---

# Use private blob containers

## SYNOPSIS

Storage Accounts use containers configured with an access type other than Private.

## DESCRIPTION

Azure Storage Account blob containers use the Private access type by default.
Additional access types Blob and Container provide anonymous access to blobs without authorized.
Blob and Container access types are not intended for access to customer data.

Blob and Container access types are designed for public access scenarios.
For example, storage of web assets like .css and .js files used in public websites.

## RECOMMENDATION

To provide secure access to data always use the Private access type (default).
Use Shared Access Signatures (SAS) to provide secure access to individual blobs or containers as required.

Consider using SAS tokens stored securely in a key vault, rotated and only accessed by approved applications.

## EXAMPLES

### Azure templates

To deploy storage accounts blob containers that pass this rule:

- Set the `properties.publicAccess` property to `None`.

For example:

```json
{
    "comments": "Create a blob container",
    "type": "Microsoft.Storage/storageAccounts/blobServices/containers",
    "apiVersion": "2019-06-01",
    "name": "[concat(parameters('storageAccountName'), '/default/', parameters('containerName')))]",
    "dependsOn": [
        "[resourceId('Microsoft.Storage/storageAccounts/blobServices', parameters('storageAccountName'), 'default')]",
        "[resourceId('Microsoft.Storage/storageAccounts', parameters('storageAccountName'))]"
    ],
    "properties": {
        "publicAccess": "None"
    }
}
```

## LINKS

- [Manage anonymous read access to containers and blobs](https://docs.microsoft.com/azure/storage/blobs/anonymous-read-access-configure)
- [How a shared access signature works](https://docs.microsoft.com/azure/storage/common/storage-sas-overview#how-a-shared-access-signature-works)
- [Key Vault Storage Account keys](https://docs.microsoft.com/azure/key-vault/secrets/overview-storage-keys)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.storage/storageaccounts)
