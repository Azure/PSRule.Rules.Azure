---
severity: Important
pillar: Reliability
category: Data management
resource: Storage Account
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Storage.UseReplication.md
---

# Use geo-replicated storage

## SYNOPSIS

Storage accounts not using geo-replicated storage (GRS) may be at risk.

## DESCRIPTION

Storage accounts can be configured with several different durability options.

## RECOMMENDATION

Consider using GRS for storage accounts that contain data.

## NOTES

Cloud Shell storage with the tag `ms-resource-usage = 'azure-cloud-shell'` is excluded.
Storage accounts used for Cloud Shell are not intended to store data.

## LINKS

- [Azure Storage redundancy](https://docs.microsoft.com/en-us/azure/storage/common/storage-redundancy)
