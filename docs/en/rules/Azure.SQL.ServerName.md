---
reviewed: 2025-10-26
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
resource: SQL Database
resourceType: Microsoft.Sql/servers
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.ServerName/
---

# Use valid SQL logical server names

## SYNOPSIS

Azure SQL logical server names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for SQL logical server names are:

- Between 1 and 63 characters long.
- Lowercase letters, numbers, and hyphens.
- Can't start or end with a hyphen.
- SQL logical server names must be globally unique.

## RECOMMENDATION

Consider using names that meet Azure SQL logical server naming requirements.
Additionally consider naming resources with a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy servers that pass this rule:

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

resource server 'Microsoft.Sql/servers@2024-05-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    minimalTlsVersion: '1.3'
    administrators: {
      azureADOnlyAuthentication: true
      administratorType: 'ActiveDirectory'
      login: adminLogin
      principalType: 'Group'
      sid: adminPrincipalId
      tenantId: tenant().tenantId
    }
  }
}
```

<!-- external:avm avm/res/sql/server name -->

### Configure with Azure template

To deploy servers that pass this rule:

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
      "type": "Microsoft.Sql/servers",
      "apiVersion": "2024-05-01-preview",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "identity": {
        "type": "SystemAssigned"
      },
      "properties": {
        "publicNetworkAccess": "Disabled",
        "minimalTlsVersion": "1.3",
        "administrators": {
          "azureADOnlyAuthentication": true,
          "administratorType": "ActiveDirectory",
          "login": "[parameters('adminLogin')]",
          "principalType": "Group",
          "sid": "[parameters('adminPrincipalId')]",
          "tenantId": "[tenant().tenantId]"
        }
      }
    }
  ]
}
```

## NOTES

This rule does not check if Azure SQL logical server names are unique.

## LINKS

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Operational Excellence maturity model](https://learn.microsoft.com/azure/well-architected/operational-excellence/maturity-model?tabs=level2)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/servers)
