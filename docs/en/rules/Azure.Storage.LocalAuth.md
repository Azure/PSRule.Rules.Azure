---
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Storage Account
resourceType: Microsoft.Storage/storageAccounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.LocalAuth/
---

# Storage account access keys are enabled

## SYNOPSIS

Access keys allow depersonalized access to Storage Accounts using a shared secret.

## DESCRIPTION

Every request to a Storage Account resource must be authenticated.
Storage Accounts support authenticating requests using either Entra ID (previously Azure AD) identities or local authentication.
Local authentication uses access keys and SAS tokens that are granted permissions to the entire Storage Account.

Using Entra ID provides consistency as a single authoritative source which:

- Increases clarity and reduces security risks from human errors and configuration complexity.
- Allows granting of permissions using role-based access control (RBAC).
- Provides support for advanced identity security and governance features.

Disabling local authentication ensures that Entra ID is used exclusively for authentication.
Any subsequent requests to the resource using access keys or SAS tokens will be rejected.

## RECOMMENDATION

Consider disabling local authentication on Storage Accounts and instead use Entra ID.

## EXAMPLES

### Configure with Bicep

To deploy Storage Accounts that pass this rule:

- Set the `properties.allowSharedKeyAccess` property to `false`.

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

<!-- external:avm avm/res/storage/storage-account allowSharedKeyAccess -->

### Configure with Azure template

To deploy Storage Accounts that pass this rule:

- Set the `properties.allowSharedKeyAccess` property to `false`.

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

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication)
- [Security: Level 1](https://learn.microsoft.com/azure/well-architected/security/maturity-model?tabs=level1)
- [Prevent Shared Key authorization for an Azure Storage account](https://learn.microsoft.com/azure/storage/common/shared-key-authorization-prevent)
- [Azure security baseline for Azure Storage](https://learn.microsoft.com/security/benchmark/azure/baselines/storage-security-baseline)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/storage-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts)
