---
reviewed: 2023-09-02
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Storage Account
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.FileShareSoftDelete/
---

# Use soft delete on files shares

## Synopsis

Enable soft delete on Storage Accounts file shares.

## Description

Soft delete for Azure Files protects your shares from being accidentally deleted.
This feature **does not** protect against individual files being deleted or modified.
When soft delete is enabled for a Azure Files on a Storage Account, a share and its contents may be recovered
after it has been deleted, within a retention period that you specify.

Soft delete on file shares should be considered _part_ of the strategy to protect and retain data for Azure Files.
Also consider:

- Enabling Azure File Share Backup.
- Implementing role-based access control (RBAC).

Storage Accounts can be configured to retain deleted share for a period of time between 1 and 365 days.

## Recommendation

Consider enabling soft delete on Azure Files to protect against accidental deletion of shares.

## Examples

### Configure with Azure template

To deploy Storage Accounts that pass this rule:

- Set the `properties.deleteRetentionPolicy.enabled` property to `true` on the `fileServices` sub-resource
- Configure the `properties.deleteRetentionPolicy.days` property to the number of days to retain files.

For example:

```json
{
  "type": "Microsoft.Storage/storageAccounts/fileServices",
  "apiVersion": "2022-05-01",
  "name": "default",
  "properties": {
    "shareDeleteRetentionPolicy": {
      "days": "7",
      "enabled": "true"
    }
  }
}
```

### Configure with Bicep

To deploy Storage Accounts that pass this rule:

- Set the `properties.deleteRetentionPolicy.enabled` property to `true` on the `fileServices` sub-resource
- Configure the `properties.deleteRetentionPolicy.days` property to the number of days to retain files.

For example:

```bicep
resource fileServices 'Microsoft.Storage/storageAccounts/fileServices@2023-01-01' = {
  parent: storageAccount
  name: 'default'
  properties: {
    shareDeleteRetentionPolicy: {
      enabled: true
      days: 7
    }
  }
}
```

<!-- external:avm avm/res/storage/storage-account fileServices -->

## Notes

Cloud Shell storage with the tag `ms-resource-usage = 'azure-cloud-shell'` is excluded.
Storage accounts used for Cloud Shell are not intended to store data.

## Links

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Storage Accounts and reliability](https://learn.microsoft.com/azure/well-architected/services/storage/storage-accounts/reliability)
- [Enable soft delete on Azure file shares](https://learn.microsoft.com/azure/storage/files/storage-files-prevent-file-share-deletion)
- [About Azure file share backup](https://learn.microsoft.com/azure/backup/azure-file-share-backup-overview)
- [Authorize access to file data](https://learn.microsoft.com/azure/storage/files/authorize-data-operations-portal)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts/fileservices)
