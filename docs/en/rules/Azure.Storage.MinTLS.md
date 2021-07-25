---
severity: Critical
pillar: Security
category: Data protection
resource: Storage Account
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.MinTLS/
---

# Storage Account minimum TLS version

## SYNOPSIS

Storage Accounts should reject TLS versions older than 1.2.

## DESCRIPTION

The minimum version of TLS that Azure Storage Accounts accept for blob storage is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Storage Accounts lets you disable outdated protocols and enforce TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 is accepted.

## RECOMMENDATION

Consider configuring the minimum supported TLS version to be 1.2.
Also consider enforcing this setting using Azure Policy.

## EXAMPLES

### Azure templates

To deploy storage accounts that pass this rule:

- Set the `properties.minimumTlsVersion` property to `TLS1_2` or newer.

For example:

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
        "minimumTlsVersion": "TLS1_2",
        "allowBlobPublicAccess": false,
        "accessTier": "Hot"
    }
}
```

## LINKS

- [Data encryption in Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Enforce a minimum required version of Transport Layer Security (TLS) for requests to a storage account](https://docs.microsoft.com/azure/storage/common/transport-layer-security-configure-minimum-version)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Use Azure Policy to enforce the minimum TLS version](https://docs.microsoft.com/azure/storage/common/transport-layer-security-configure-minimum-version#use-azure-policy-to-enforce-the-minimum-tls-version)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.storage/storageaccounts#StorageAccountPropertiesCreateParameters)
