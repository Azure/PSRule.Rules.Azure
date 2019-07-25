---
severity: Important
category: Data recovery
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.Storage.SoftDelete.md
ms-content-id: 9927b427-e694-4485-9abf-61545e63956e
---

# Azure.Storage.SoftDelete

## SYNOPSIS

Enable soft delete on Storage Accounts.

## DESCRIPTION

Soft delete on Azure Storage Accounts is not enabled.

Soft delete provides an easy way to recover deleted or modified data stored as blobs within a Storage Account within a configured interval.

## RECOMMENDATION

Consider enabling soft delete on storage accounts to protect blobs from accidental deletion or modification.

Also consider implementing role-based access control (RBAC), Resource Locks and backups blobs to protect against storage accounts or blob containers being deleted.

For more information see [Soft delete for Azure Storage blobs](https://docs.microsoft.com/en-us/azure/storage/blobs/storage-blob-soft-delete) and [RBAC operations for Storage](https://docs.microsoft.com/en-us/azure/role-based-access-control/resource-provider-operations#microsoftstorage)
