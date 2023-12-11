---
reviewed: 2023-07-15
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

### Configure with Bicep Public Registry

To deploy App Configuration Stores that pass this rule:

- Set the `params.skuName` parameter to `Standard`.

For example:

```bicep
module br_public_store 'br/public:app/app-configuration:1.1.2' = {
  name: 'store'
  params: {
    skuName: 'Standard'
    disableLocalAuth: true
    enablePurgeProtection: true
    publicNetworkAccess: 'Disabled'
    replicas: [
      {
        name: 'eastus'
        location: 'eastus'
      }
    ]
  }
}
```

## LINKS

- [Meet application platform requirements](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-requirements#meet-application-platform-requirements)
- [App Configuration pricing](https://azure.microsoft.com/pricing/details/app-configuration/)
- [Which App Configuration tier should I use?](https://learn.microsoft.com/azure/azure-app-configuration/faq#which-app-configuration-tier-should-i-use)
- [Bicep public registry](https://azure.github.io/bicep-registry-modules/#app)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores)
