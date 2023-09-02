---
severity: Important
pillar: Security
category: Authentication
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

## LINKS

- [Use Azure AD for storage authentication](https://docs.microsoft.com/azure/security/fundamentals/identity-management-best-practices#use-azure-ad-for-storage-authentication)
- [Allow or disallow public read access for a storage account](https://docs.microsoft.com/azure/storage/blobs/anonymous-read-access-configure#allow-or-disallow-public-read-access-for-a-storage-account)
- [Remediate anonymous public access](https://docs.microsoft.com/azure/storage/blobs/anonymous-read-access-prevent#remediate-anonymous-public-access)
- [Use Azure Policy to enforce authorized access](https://docs.microsoft.com/azure/storage/blobs/anonymous-read-access-prevent#use-azure-policy-to-enforce-authorized-access)
- [Authorize access to blobs using Azure Active Directory](https://docs.microsoft.com/azure/storage/blobs/authorize-access-azure-active-directory)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts)
