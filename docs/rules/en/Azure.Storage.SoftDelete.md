---
severity: Important
pillar: Reliability
category: Data management
resource: Storage Account
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Storage.SoftDelete.md
ms-content-id: 9927b427-e694-4485-9abf-61545e63956e
---

# Use blob soft delete

## SYNOPSIS

Enable blob soft delete on Storage Accounts.

## DESCRIPTION

Soft delete provides an easy way to recover deleted or modified blob data stored within Storage Accounts.
When soft delete is enabled, the configured retention interval determines the period of time deleted blobs are kept.

## RECOMMENDATION

Consider enabling soft delete on storage accounts to protect blobs from accidental deletion or modification.
Also consider implementing role-based access control (RBAC), Resource Locks, and backups blobs to protect against storage accounts or blob containers being deleted.

## NOTES

Cloud Shell storage with the tag `ms-resource-usage = 'azure-cloud-shell'` is excluded.
Storage accounts used for Cloud Shell are not intended to store data.

Storage accounts with hierarchical namespace enabled to not support blob soft delete.

## LINKS

- [Soft delete for Azure Storage blobs](https://docs.microsoft.com/azure/storage/blobs/soft-delete-blob-overview)
- [RBAC operations for Storage](https://docs.microsoft.com/azure/role-based-access-control/resource-provider-operations#microsoftstorage)
- [Blob storage features available in Azure Data Lake Storage Gen2](https://docs.microsoft.com/azure/storage/blobs/data-lake-storage-supported-blob-storage-features)
