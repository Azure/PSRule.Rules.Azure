---
severity: Important
pillar: Reliability
category: Data management
resource: App Configuration
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppConfig.PurgeProtect/
---

# Purge Protect App Configuration Stores

## SYNOPSIS

Consider purge protection for app configuration store to ensure store cannot be purged in the retention period.

## DESCRIPTION

With purge protection enabled, soft deleted stores can't be purged in the retention period. If disabled, the soft deleted store can be purged before the retention period expires. Once purge protection is enabled on a store, it can't be disabled.

Purge protection currently requires a **standard** SKU.

## RECOMMENDATION

Consider enabling purge protection for app configuration store.

## EXAMPLES

### Configure with Azure template

To deploy App Configuration Stores that pass this rule:

- Set `properties.enablePurgeProtection` to `true`.

For example:

```json
{
  "type": "Microsoft.AppConfiguration/configurationStores",
  "apiVersion": "2022-05-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "standard"
  },
  "properties": {
    "disableLocalAuth": true,
    "enablePurgeProtection": true
  }
}
```

### Configure with Bicep

To deploy App Configuration Stores that pass this rule:

- Set `properties.enablePurgeProtection` to `true`.

For example:

```bicep
resource store 'Microsoft.AppConfiguration/configurationStores@2022-05-01' = {
  name: name
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    disableLocalAuth: true
    enablePurgeProtection: true
  }
}
```

## LINKS

- [Data management for reliability](https://learn.microsoft.com/azure/architecture/framework/resiliency/data-management)
- [Purge protection](https://learn.microsoft.com/azure/azure-app-configuration/concept-soft-delete#purge-protection)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores)
