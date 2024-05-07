---
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Storage Account
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.BlobPublicAccess/
---

# Disallow anonymous access to blob service

## SYNOPSIS

Storage Accounts should only accept authorized requests.

## DESCRIPTION

Blob containers in Azure Storage Accounts can be configured for private or anonymous public access.
By default, containers are private and only accessible with a credential or access token.
When a container is configured with an access type other than private, anonymous access is permitted.

Anonymous access to blobs or containers can be restricted by setting `allowBlobPublicAccess` to `false`.
This enhanced security setting for a storage account overrides the individual settings for blob containers.
When you disallow public access for a storage account, blobs are no longer accessible anonymously.

## RECOMMENDATION

Consider disallowing anonymous access to storage account blobs unless specifically required.
Also consider enforcing this setting using Azure Policy.

## EXAMPLES

### Configure with Azure template

To deploy Storage Accounts that pass this rule:

- Set the `properties.allowBlobPublicAccess` property to `false`.

For example:

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
  }
}
```

### Configure with Bicep

To deploy Storage Accounts that pass this rule:

- Set the `properties.allowBlobPublicAccess` property to `false`.

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
```

<!-- external:avm avm/res/storage/storage-account allowBlobPublicAccess -->

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Configure your Storage account public access to be disallowed](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Storage/StorageAccountDisablePublicBlobAccess_Modify.json)
  `/providers/Microsoft.Authorization/policyDefinitions/13502221-8df0-4414-9937-de9c5c4e396b`

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [Use Microsoft Entra ID for storage authentication](https://learn.microsoft.com/azure/security/fundamentals/identity-management-best-practices#use-microsoft-entra-id-for-storage-authentication)
- [Configure anonymous read access for containers and blobs](https://learn.microsoft.com/azure/storage/blobs/anonymous-read-access-configure)
- [Remediate anonymous read access to blob data](https://learn.microsoft.com/azure/storage/blobs/anonymous-read-access-prevent)
- [Authorize access to blobs using Microsoft Entra ID](https://learn.microsoft.com/azure/storage/blobs/authorize-access-azure-active-directory)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts)
