---
reviewed: 2023-07-15
severity: Important
pillar: Reliability
category: Data management
resource: App Configuration
resourceType: Microsoft.AppConfiguration/configurationStores
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppConfig.PurgeProtect/
---

# Purge Protect App Configuration Stores

## SYNOPSIS

Consider purge protection for app configuration store to ensure store cannot be purged in the retention period.

## DESCRIPTION

With purge protection enabled, soft deleted stores can't be purged in the retention period.
If disabled, the soft deleted store can be purged before the retention period expires.
Once purge protection is enabled on a store, it can't be disabled.

Purge protection is only available for configuration stores that use the **standard** SKU.

## RECOMMENDATION

Consider enabling purge protection for app configuration stores.

## EXAMPLES

### Configure with Azure template

To deploy App Configuration Stores that pass this rule:

- Set the `properties.enablePurgeProtection` property to `true`.

For example:

```json
{
  "type": "Microsoft.AppConfiguration/configurationStores",
  "apiVersion": "2023-03-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "standard"
  },
  "properties": {
    "disableLocalAuth": true,
    "enablePurgeProtection": true,
    "publicNetworkAccess": "Disabled"
  }
}
```

### Configure with Bicep

To deploy App Configuration Stores that pass this rule:

- Set the `properties.enablePurgeProtection` property to `true`.

For example:

```bicep
resource store 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: name
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    disableLocalAuth: true
    enablePurgeProtection: true
    publicNetworkAccess: 'Disabled'
  }
}
```

<!-- external:avm avm/res/app-configuration/configuration-store enablePurgeProtection -->

## LINKS

- [Data management for reliability](https://learn.microsoft.com/azure/architecture/framework/resiliency/data-management)
- [Purge protection](https://learn.microsoft.com/azure/azure-app-configuration/concept-soft-delete#purge-protection)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores)
