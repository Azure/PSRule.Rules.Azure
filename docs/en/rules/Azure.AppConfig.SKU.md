---
reviewed: 2021/12/20
severity: Important
pillar: Reliability
category: Requirements
resource: App Configuration
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

To deploy App Configuration Stores that pass this rule:

- Set `sku.name` to `standard`.

For example:

```json
{
  "type": "Microsoft.AppConfiguration/configurationStores",
  "apiVersion": "2020-06-01",
  "name": "[parameters('storeName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "standard"
  }
}
```

### Configure with Bicep

To deploy App Configuration Stores that pass this rule:

- Set `sku.name` to `standard`.

For example:

```bicep
resource configStore 'Microsoft.AppConfiguration/configurationStores@2020-06-01' = {
  name: storeName
  location: location
  sku: {
    name: 'standard'
  }
}
```

## LINKS

- [Target and non-functional requirements](https://docs.microsoft.com/azure/architecture/framework/resiliency/design-requirements)
- [App Configuration pricing](https://azure.microsoft.com/pricing/details/app-configuration/)
- [Which App Configuration tier should I use?](https://docs.microsoft.com/azure/azure-app-configuration/faq#which-app-configuration-tier-should-i-use)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores)
