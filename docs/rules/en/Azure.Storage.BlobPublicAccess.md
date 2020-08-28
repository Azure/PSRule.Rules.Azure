---
severity: Important
pillar: Security
category: Identity and access management
resource: Storage Account
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Storage.BlobPublicAccess.md
---

# Disallow anonymous access to blob service

## SYNOPSIS

Storage Accounts should only accept authorized requests.

## DESCRIPTION

Blob containers in Azure Storage Accounts can be configured for private or anonymous public access.
By default, containers are private and only accessible with a credential or access token.
When a container is configured with an access type other than private, anonymous access is permitted.

Anonymous access to blobs or containers can be restricted by setting `AllowBlobPublicAccess` to `false`.
This enhanced security setting for a storage account overrides the individual settings for blob containers.
When you disallow public access for a storage account, blobs are no longer accessible anonymously.

## RECOMMENDATION

Consider disallowing anonymous access to storage account blobs unless specifically required.
Also consider enforcing this setting using Azure Policy.

## LINKS

- [Allow or disallow public read access for a storage account](https://docs.microsoft.com/en-us/azure/storage/blobs/anonymous-read-access-configure#allow-or-disallow-public-read-access-for-a-storage-account)
- [Remediate anonymous public access](https://docs.microsoft.com/en-us/azure/storage/blobs/anonymous-read-access-prevent#remediate-anonymous-public-access)
- [Use Azure Policy to enforce authorized access](https://docs.microsoft.com/en-us/azure/storage/blobs/anonymous-read-access-prevent#use-azure-policy-to-enforce-authorized-access)
- [Azure template reference](https://docs.microsoft.com/en-us/azure/templates/microsoft.storage/storageaccounts#StorageAccountPropertiesCreateParameters)
