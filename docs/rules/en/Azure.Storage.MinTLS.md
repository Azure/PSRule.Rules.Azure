---
severity: Critical
pillar: Security
category: Encryption
resource: Storage Account
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Storage.MinTLS.md
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

## LINKS

- [Enforce a minimum required version of Transport Layer Security (TLS) for requests to a storage account](https://docs.microsoft.com/en-us/azure/storage/common/transport-layer-security-configure-minimum-version)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/en-us/updates/azuretls12/)
- [Use Azure Policy to enforce the minimum TLS version](https://docs.microsoft.com/en-us/azure/storage/common/transport-layer-security-configure-minimum-version#use-azure-policy-to-enforce-the-minimum-tls-version)
- [Azure template reference](https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts#StorageAccountPropertiesCreateParameters)
