---
reviewed: 2023-07-15
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: App Configuration
resourceType: Microsoft.AppConfiguration/configurationStores
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppConfig.SKU/
---

# Use production App Configuration SKU

## SYNOPSIS

App Configuration should use a minimum size of Standard.

## DESCRIPTION

App Configuration is offered in two different SKUs; Free, and Standard.
Standard includes additional features, increases scalability, and 99.9% SLA.
The Free SKU does not include a SLA.

## RECOMMENDATION

Consider upgrading App Configuration instances to Standard.
Free instances are intended only for early development and testing scenarios.

## EXAMPLES

### Configure with Azure template

To deploy configuration stores that pass this rule:

- Set the `sku.name` property to `standard`.

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

To deploy configuration stores that pass this rule:

- Set the `sku.name` property to `standard`.

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

<!-- external:avm avm/res/app-configuration/configuration-store sku -->

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [App Configuration pricing](https://azure.microsoft.com/pricing/details/app-configuration/)
- [Which App Configuration tier should I use?](https://learn.microsoft.com/azure/azure-app-configuration/faq#which-app-configuration-tier-should-i-use)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores)
