---
reviewed: 2024-03-04
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Storage Account
resourceType: Microsoft.Storage/storageAccounts,Microsoft.Storage/storageAccounts/blobServices/containers
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.BlobAccessType/
---

# Use private blob containers

## SYNOPSIS

Use containers configured with a private access type that requires authorization.

## DESCRIPTION

Azure Storage Account blob containers use the Private access type by default.
Additional access types Blob and Container provide anonymous access to blobs without authorization.
Blob and Container access types are not intended for access to customer data.
When authorization is required, clients must use cryptographic keys or identity-based tokens to authenticate.

Blob and Container access types are designed for public access scenarios.
For example, storage of web assets like .css and .js files used in public websites.

## RECOMMENDATION

To provide secure access to data always use the Private access type (default).
Also consider, disabling public access for the storage account.

## EXAMPLES

### Configure with Azure template

To deploy Storage Account blob containers that pass this rule:

- Set the `properties.publicAccess` property to `None`.

For example:

```json
{
  "type": "Microsoft.Storage/storageAccounts/blobServices/containers",
  "apiVersion": "2021-06-01",
  "name": "[format('{0}/{1}/{2}', parameters('name'), 'default', variables('containerName'))]",
  "properties": {
    "publicAccess": "None"
  },
  "dependsOn": [
    "[resourceId('Microsoft.Storage/storageAccounts/blobServices', parameters('name'), 'default')]",
    "[resourceId('Microsoft.Storage/storageAccounts', parameters('name'))]"
  ]
}
```

### Configure with Bicep

To deploy Storage Account blob containers that pass this rule:

- Set the `properties.publicAccess` property to `None`.

For example:

```bicep
resource container 'Microsoft.Storage/storageAccounts/blobServices/containers@2021-06-01' = {
  parent: blobService
  name: containerName
  properties: {
    publicAccess: 'None'
  }
}
```

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [Use Microsoft Entra ID for storage authentication](https://learn.microsoft.com/azure/security/fundamentals/identity-management-best-practices#use-microsoft-entra-id-for-storage-authentication)
- [Configure anonymous read access for containers and blobs](https://learn.microsoft.com/azure/storage/blobs/anonymous-read-access-configure)
- [Remediate anonymous read access to blob data](https://learn.microsoft.com/azure/storage/blobs/anonymous-read-access-prevent)
- [How a shared access signature works](https://learn.microsoft.com/azure/storage/common/storage-sas-overview#how-a-shared-access-signature-works)
- [Authorize access to blobs using Microsoft Entra ID](https://learn.microsoft.com/azure/storage/blobs/authorize-access-azure-active-directory)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts)
