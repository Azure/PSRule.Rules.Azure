---
reviewed: 2022-09-24
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: App Configuration
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppConfig.Name/
---

# Use valid App Configuration store names

## SYNOPSIS

App Configuration store names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for App Configuration store names are:

- Between 5 and 50 characters long.
- Alphanumerics and hyphens.
- Start and end with a letter or number.
- App Configuration store names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet App Configuration store naming requirements.
Additionally consider naming resources with a standard naming convention.

## EXAMPLES

### Configure with Azure template

To deploy configuration stores that pass this rule:

- Set `name` to a value that meets the requirements.

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

To deploy configuration stores that pass this rule:

- Set `name` to a value that meets the requirements.

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

### Configure with Bicep Public Registry

To deploy App Configuration Stores that pass this rule:

- Set `params.name` to a value that meets the requirements.

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

## NOTES

This rule does not check if App Configuration store names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules#microsoftappconfiguration)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
