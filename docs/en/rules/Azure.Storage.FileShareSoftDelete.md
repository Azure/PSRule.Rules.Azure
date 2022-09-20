---
reviewed: 2022-09-19
severity: Important
pillar: Reliability
category: Data Management
resource: Storage Account
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.FileShareSoftDelete/
---

# Use fileshare soft delete

## Synopsis

Enable fileshare soft delete on Storage Accounts

## Description

Azure Files offers soft delete for fileshares within Storage Accounts to recover deleted or modified files.

## Recommendation

Consider enabling soft delete on fileshares to protect files from accidential deletion or modification.

## Examples

### Configure with Azure template

To deploy Fileshares via ARM that pass this rule:

- Set the `properties.deleteRetentionPolicy.enabled` property to `true` on the fileshare services sub-resource
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

To deploy Fileshares via Bicep that pass this rule:

- Set the `properties.deleteRetentionPolicy.enabled` property to `true` on the fileshare services sub-resource
- Configure the `properties.deleteRetentionPolicy.days` property to the number of days to retain files.

For example:

```bicep

resource  'Microsoft.Storage/storageAccounts/fileServices@2022-05-01' = {
  name: 'default'
  parent: st0000001
    shareDeleteRetentionPolicy: {
      days: 7
      enabled: true
    }
  }
}

```

## Notes

Cloud Shell storage with the tag `ms-resource-usage = 'azure-cloud-shell'` is excluded. Storage accounts used for Cloud Shell are not intended to store data.

## Links

- [Enable soft delete on Azure file shares](https://docs.microsoft.com/azure/storage/files/storage-files-enable-soft-delete?tabs=azure-portal)
- [RBAC operations for storage](https://docs.microsoft.com/azure/role-based-access-control/resource-provider-operations#microsoftstorage)
- [What is Azure Files?](https://docs.microsoft.com/azure/storage/files/storage-files-introduction)
- [Microsoft.Storage storageAccounts/fileServices](https://docs.microsoft.com/azure/templates/microsoft.storage/storageaccounts/fileservices)
