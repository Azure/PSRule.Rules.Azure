---
reviewed: 2025-10-26
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
resource: SQL Database
resourceType: Microsoft.Sql/servers/databases
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.DBName/
---

# Use valid SQL Database names

## SYNOPSIS

Azure SQL Database names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for SQL Database names are:

- Between 1 and 128 characters long.
- Letters, numbers, and special characters except: `<>*%&:\/?`
- Can't end with period or a space.
- Azure SQL Database names must be unique for each logical server.

The following reserved database names can not be used:

- `master`
- `model`
- `tempdb`

## RECOMMENDATION

Consider using names that meet Azure SQL Database naming requirements.
Additionally consider naming resources with a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy databases that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
@minLength(1)
@maxLength(128)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

resource database 'Microsoft.Sql/servers/databases@2024-05-01-preview' = {
  parent: server
  name: name
  location: location
  properties: {
    collation: 'SQL_Latin1_General_CP1_CI_AS'
    maxSizeBytes: maxSize
    catalogCollation: 'SQL_Latin1_General_CP1_CI_AS'
    readScale: 'Disabled'
    zoneRedundant: true
  }
}
```

### Configure with Azure template

To deploy databases that pass this rule:

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
      "maxLength": 128,
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
      "type": "Microsoft.Sql/servers/databases",
      "apiVersion": "2024-05-01-preview",
      "name": "[format('{0}/{1}', parameters('name'), parameters('name'))]",
      "location": "[parameters('location')]",
      "properties": {
        "collation": "SQL_Latin1_General_CP1_CI_AS",
        "maxSizeBytes": "[variables('maxSize')]",
        "catalogCollation": "SQL_Latin1_General_CP1_CI_AS",
        "readScale": "Disabled",
        "zoneRedundant": true
      }
    }
  ]
}
```

## NOTES

This rule does not check if Azure SQL Database names are unique.

## LINKS

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Operational Excellence maturity model](https://learn.microsoft.com/azure/well-architected/operational-excellence/maturity-model?tabs=level2)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/servers/databases)
