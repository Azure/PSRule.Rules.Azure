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

Enable soft delete on Storage Accounts.

## DESCRIPTION

Soft delete on Azure Storage Accounts is not enabled.
Soft delete provides an easy way to recover deleted or modified blob data stored within Storage Accounts.

When soft delete is enabled, the configured retention interval determines the period of time deleted blobs are kept.

## RECOMMENDATION

Consider enabling soft delete on storage accounts to protect blobs from accidental deletion or modification.

Also consider implementing role-based access control (RBAC), Resource Locks and backups blobs to protect against storage accounts or blob containers being deleted.

## NOTES

Cloud Shell storage with the tag `ms-resource-usage = 'azure-cloud-shell'` is excluded.
Storage accounts used for Cloud Shell are not intended to store data.

## LINKS

- [Soft delete for Azure Storage blobs](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-soft-delete)
- [RBAC operations for Storage](https://docs.microsoft.com/en-us/azure/role-based-access-control/resource-provider-operations#microsoftstorage)
