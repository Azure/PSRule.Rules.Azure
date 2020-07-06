---
severity: Important
category: Security configuration
resource: Storage
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Storage.BlobAccessType.md
---

# Use private blob container

## SYNOPSIS

Storage Accounts use containers configured with an access type other than Private.

## DESCRIPTION

Azure Storage Account blob containers use the Private access type by default.
Additional access types Blob and Container provide anonymous access to blobs without authentication.
Blob and Container access types are not intended for access to customer data.

Blob and Container access types are designed for public access scenarios.
For example, Content Delivery Network (CDN) and storage of web assets like .css and .js files in public websites.

## RECOMMENDATION

To provide secure access to data always use the Private access type (default).
Then use Shared Access Signatures (SAS) to provide secure access to individual blobs or containers as required.

Consider using SAS tokens stored securely in a key vault, rotated and only accessed by approved applications.

## LINKS

- [Manage anonymous read access to containers and blobs](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-manage-access-to-resources)
- [How a shared access signature works](https://docs.microsoft.com/en-us/azure/storage/common/storage-sas-overview#how-a-shared-access-signature-works)
- [Key Vault Storage Account keys](https://docs.microsoft.com/en-us/azure/key-vault/key-vault-ovw-storage-keys)
