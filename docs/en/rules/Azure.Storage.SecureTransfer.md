---
severity: Important
pillar: Security
category: Encryption
resource: Storage Account
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.SecureTransfer/
ms-content-id: 539cb7b9-5510-4aa3-b422-41a049a10a88
---

# Enforce encrypted Storage connections

## SYNOPSIS

Storage accounts should only accept encrypted connections.

## DESCRIPTION

Azure Storage Accounts can be configured to allow unencrypted connections.
Unencrypted communication could allow disclosure of information to an un-trusted party.
Storage Accounts can be configured to require encrypted connections.

To do this set the _Secure transfer required_ option.
When _secure transfer required_ is enabled,
attempts to connect to storage using HTTP or unencrypted SMB connections are rejected.

## RECOMMENDATION

Storage accounts should only accept secure traffic.
Consider only accepting encrypted connections by setting the _Secure transfer required_ option.
Also consider using Azure Policy to audit or enforce this configuration.

## EXAMPLES

### Configure with Azure template

To deploy Storage Accounts that pass this rule:

- Set the `properties.supportsHttpsTrafficOnly` property to `true`.

For example:

```json
{
    "comments": "Storage Account",
    "type": "Microsoft.Storage/storageAccounts",
    "apiVersion": "2019-06-01",
    "name": "st0000001",
    "location": "[parameters('location')]",
    "sku": {
        "name": "Standard_GRS",
        "tier": "Standard"
    },
    "kind": "StorageV2",
    "properties": {
        "supportsHttpsTrafficOnly": true,
        "minimumTlsVersion": "TLS1_2",
        "allowBlobPublicAccess": false,
        "accessTier": "Hot"
    }
}
```

### Configure with Bicep

To deploy Storage Accounts that pass this rule:

- Set the `properties.supportsHttpsTrafficOnly` property to `true`.

For example:

```bicep
resource st0000001 'Microsoft.Storage/storageAccounts@2021-04-01' = {
  name: 'st0000001'
  location: location
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
  properties: {
    supportsHttpsTrafficOnly: true
    accessTier: 'Hot'
    allowBlobPublicAccess: false
    minimumTlsVersion: 'TLS1_2'
  }
}
```

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Require secure transfer in Azure Storage](https://docs.microsoft.com/azure/storage/common/storage-require-secure-transfer)
- [Sample policy for ensuring https traffic](https://docs.microsoft.com/azure/governance/policy/samples/ensure-https-stor-acct)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.storage/storageaccounts)
