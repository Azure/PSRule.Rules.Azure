---
reviewed: 2024-03-04
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: Storage Account
resourceType: Microsoft.Storage/storageAccounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.MinTLS/
---

# Use secure protocols for Storage Accounts

## SYNOPSIS

Storage Accounts should not accept weak or deprecated transport protocols for client-server communication.

## DESCRIPTION

The minimum version of TLS that Azure Storage Accounts accept for blob storage is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Storage Accounts lets you disable outdated protocols and enforce TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 is accepted.

When clients connect using an older version of TLS that is disabled, the connection will fail.

## RECOMMENDATION

Consider configuring the minimum supported TLS version to be 1.2.
Also consider enforcing this setting using Azure Policy.

## EXAMPLES

### Configure with Azure template

To deploy Storage Accounts that pass this rule:

- Set the `properties.minimumTlsVersion` property to `TLS1_2` or newer.

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

- Set the `properties.minimumTlsVersion` property to `TLS1_2` or newer.

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

<!-- external:avm avm/res/storage/storage-account minimumTlsVersion -->

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Storage accounts should have the specified minimum TLS version](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Storage/StorageAccountMinimumTLSVersion_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/fe83a0eb-a853-422d-aac2-1bffd182c5d0`

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#data-in-transit)
- [Enforce a minimum required version of Transport Layer Security (TLS) for requests to a storage account](https://learn.microsoft.com/azure/storage/common/transport-layer-security-configure-minimum-version)
- [DP-3: Encrypt sensitive data in transit](https://learn.microsoft.com/security/benchmark/azure/baselines/storage-security-baseline#dp-3-encrypt-sensitive-data-in-transit)
- [TLS encryption in Azure](https://learn.microsoft.com/azure/security/fundamentals/encryption-overview#tls-encryption-in-azure)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Use Azure Policy to enforce the minimum TLS version](https://learn.microsoft.com/azure/storage/common/transport-layer-security-configure-minimum-version?tabs=portal#use-azure-policy-to-enforce-the-minimum-tls-version)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts)
