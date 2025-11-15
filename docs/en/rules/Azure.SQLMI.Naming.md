---
reviewed: 2025-11-16
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: SQL Managed Instance
resourceType: Microsoft.Sql/managedInstances
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQLMI.Naming/
---

# SQL Managed Instance resources must use standard naming

## SYNOPSIS

SQL Managed Instance resources without a standard naming convention may be difficult to identify and manage.

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

For SQL Managed Instance, the Cloud Adoption Framework (CAF) recommends using the `sqlmi-` prefix.

Requirements for SQL Managed Instance resource names:

- Between 1 and 63 characters long.
- Lowercase letters, numbers, and hyphens.
- Can't start or end with a hyphen.
- SQL Managed Instance names must be globally unique.

## RECOMMENDATION

Consider creating SQL Managed Instance resources with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy resources that pass this rule:

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

resource managedInstance 'Microsoft.Sql/managedInstances@2023-08-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'GP_Gen5'
  }
  properties: {
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: login
      sid: sid
      principalType: 'Group'
      tenantId: tenant().tenantId
    }
    maintenanceConfigurationId: maintenanceWindow.id
  }
}
```

<!-- external:avm avm/res/sql/managed-instance name -->

### Configure with Azure template

To deploy resources that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 63,
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
      "type": "Microsoft.Sql/managedInstances",
      "apiVersion": "2023-08-01",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "identity": {
        "type": "SystemAssigned"
      },
      "sku": {
        "name": "GP_Gen5"
      },
      "properties": {
        "administrators": {
          "administratorType": "ActiveDirectory",
          "azureADOnlyAuthentication": true,
          "login": "[parameters('login')]",
          "sid": "[parameters('sid')]",
          "principalType": "Group",
          "tenantId": "[tenant().tenantId]"
        },
        "maintenanceConfigurationId": "[subscriptionResourceId('Microsoft.Maintenance/publicMaintenanceConfigurations', 'SQL_WestEurope_MI_1')]"
      }
    }
  ]
}
```

## NOTES

This rule does not check if SQL Managed Instance resource names are unique.

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_SQL_MI_NAME_FORMAT -->

To configure this rule set the `AZURE_SQL_MI_NAME_FORMAT` configuration value to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_SQL_MI_NAME_FORMAT: '^sqlmi-'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Operational Excellence: Level 2](https://learn.microsoft.com/azure/well-architected/operational-excellence/maturity-model?tabs=level2)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
