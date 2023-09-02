---
severity: Important
pillar: Reliability
category: Requirements
resource: Storage Account
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Storage.UseReplication/
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

## EXAMPLES

### Configure with Azure template

To deploy Storage Accounts that pass this rule:

- Set the `sku.name` property to a geo-replicated SKU.
  Such as `Standard_GRS`.

For example:

```json
{
  "type": "Microsoft.Storage/storageAccounts",
  "apiVersion": "2023-01-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard_GRS"
  },
  "kind": "StorageV2",
  "properties": {
    "allowBlobPublicAccess": false,
    "supportsHttpsTrafficOnly": true,
    "minimumTlsVersion": "TLS1_2",
    "accessTier": "Hot",
    "allowSharedKeyAccess": false,
    "networkAcls": {
      "defaultAction": "Deny"
    }
  }
}
```

### Configure with Bicep

To deploy Storage Accounts that pass this rule:

- Set the `sku.name` property to a geo-replicated SKU.
  Such as `Standard_GRS`.

For example:

```bicep
resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    accessTier: 'Hot'
    allowSharedKeyAccess: false
    networkAcls: {
      defaultAction: 'Deny'
    }
  }
}
```

## NOTES

This rule is not applicable for premium storage accounts.
Storage Accounts with the following tags are automatically excluded from this rule:

- `ms-resource-usage = 'azure-cloud-shell'` - Storage Accounts used for Cloud Shell are not intended to store data.
  This tag is applied by Azure to Cloud Shell Storage Accounts by default.
- `resource-usage = 'azure-functions'` - Storage Accounts used for Azure Functions.
  This tag can be optionally configured.
- `resource-usage = 'azure-monitor'` - Storage Accounts used by Azure Monitor are intended for diagnostic logs.
  This tag can be optionally configured.

## LINKS

- [Meet application platform requirements](https://learn.microsoft.com/azure/well-architected/resiliency/design-requirements#meet-application-platform-requirements)
- [Azure Storage redundancy](https://learn.microsoft.com/azure/storage/common/storage-redundancy)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.storage/storageaccounts)
