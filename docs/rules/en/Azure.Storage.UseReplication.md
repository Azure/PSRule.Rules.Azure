---
severity: Important
pillar: Reliability
category: Data management
resource: Storage Account
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Storage.UseReplication.md
---

# Use geo-replicated storage

## SYNOPSIS

Storage Accounts not using geo-replicated storage (GRS) may be at risk.

## DESCRIPTION

Storage Accounts can be configured with several different durability options.
Azure provides a number of geo-replicated options including;
Geo-redundant storage and geo-zone-redundant storage.
Geo-zone-redundant storage is only available in supported regions.

The following geo-replicated options are available within Azure:

- `Standard_GRS`
- `Standard_RAGRS`
- `Standard_GZRS`
- `Standard_RAGZRS`

## RECOMMENDATION

Consider using GRS for storage accounts that contain data.

## NOTES

Storage Accounts with the following tags are automatically excluded from this rule:

- `ms-resource-usage = 'azure-cloud-shell'` - Storage Accounts used for Cloud Shell are not intended to store data.
This tag is applied by Azure to Cloud Shell Storage Accounts by default.
- `resource-usage = 'azure-functions'` - Storage Accounts used for Azure Functions.
This tag can be optionally configured.
- `resource-usage = 'azure-monitor'` - Storage Accounts used by Azure Monitor are intended for diagnostic logs.
This tag can be optionally configured.

## LINKS

- [Azure Storage redundancy](https://docs.microsoft.com/azure/storage/common/storage-redundancy)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.storage/storageaccounts)
