---
reviewed: 2025-11-16
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Azure Cache for Redis Enterprise
resourceType: Microsoft.Cache/redisEnterprise
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.RedisEnterprise.Naming/
---

# Azure Cache for Redis Enterprise resources must use standard naming

## SYNOPSIS

Azure Cache for Redis Enterprise resources without a standard naming convention may be difficult to identify and manage.

## DESCRIPTION

An effective naming convention allows operators to quickly identify resources, related systems, and their purpose.
Identifying resources easily is important to improve operational efficiency, reduce the time to respond to incidents,
and minimize the risk of human error.

Some of the benefits of using standardized tagging and naming conventions are:

- They provide consistency and clarity for resource identification and discovery across the Azure Portal, CLIs, and APIs.
- They enable filtering and grouping of resources for billing, monitoring, security, and compliance purposes.
- They support resource lifecycle management, such as provisioning, decommissioning, backup, and recovery.

For example, if you come upon a security incident, it's critical to quickly identify affected systems,
the functions that those systems support, and the potential business impact.

For Azure Cache for Redis Enterprise, the Cloud Adoption Framework (CAF) recommends using the `redis-` prefix.

Requirements for Azure Cache for Redis Enterprise resource names:

- Between 1 and 63 characters long.
- Can include alphanumeric, and hyphen characters.
- Can only start and end with a letter or number.
- Cache names must be globally unique.

## RECOMMENDATION

Consider creating Azure Cache for Redis Enterprise resources with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy enterprise caches that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
@minLength(1)
@maxLength(63)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

resource cache 'Microsoft.Cache/redisEnterprise@2025-04-01' = {
  name: name
  location: location
  sku: {
    name: 'Enterprise_E10'
  }
  properties: {
    minimumTlsVersion: '1.2'
  }
}
```

<!-- external:avm avm/res/cache/redis-enterprise name -->

### Configure with Azure template

To deploy enterprise caches that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "name": {
      "type": "string",
      "minLength": 2,
      "maxLength": 64,
      "metadata": {
        "description": "The name of the resource."
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "The location resources will be deployed."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.Cache/redis",
      "apiVersion": "2024-11-01",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "properties": {
        "redisVersion": "6",
        "sku": {
          "name": "Premium",
          "family": "P",
          "capacity": 1
        },
        "redisConfiguration": {
          "aad-enabled": "True",
          "maxmemory-reserved": "615"
        },
        "enableNonSslPort": false,
        "publicNetworkAccess": "Disabled",
        "disableAccessKeyAuthentication": true
      },
      "zones": [
        "1",
        "2",
        "3"
      ]
    }
  ]
}
```

## NOTES

This rule does not check if Azure Cache for Redis resource names are unique.

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_REDIS_ENTERPRISE_NAME_FORMAT -->

To configure this rule set the `AZURE_REDIS_ENTERPRISE_NAME_FORMAT` configuration value to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_REDIS_ENTERPRISE_NAME_FORMAT: '^redis-'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Operational Excellence: Level 2](https://learn.microsoft.com/azure/well-architected/operational-excellence/maturity-model?tabs=level2)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cache/redisenterprise)
