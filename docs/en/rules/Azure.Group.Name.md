---
reviewed: 2025-04-11
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
resource: Resource Group
resourceType: Microsoft.Resources/resourceGroups
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Group.Name/
---

# Resource Group name must be valid

## SYNOPSIS

Azure Resource Manager (ARM) has requirements for Resource Groups names.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Resource Group names are:

- Between 1 and 90 characters long.
- Alphanumerics, underscores, parentheses, hyphens, periods.
- Can't end with period.
- Resource Group names must be unique within a subscription.

## RECOMMENDATION

Consider using names that meet Resource Group naming requirements.
Additionally consider naming resources with a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy resource groups that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
targetScope = 'subscription'

@minLength(1)
@maxLength(90)
@description('The name of the resource group.')
param name string

@description('The location resource group will be deployed.')
param location string

resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: name
  location: location
  tags: {
    environment: 'production'
    costCode: '349921'
  }
}
```

<!-- external:avm avm/res/resources/resource-group name -->

### Configure with Azure template

To deploy resource groups that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "metadata": {
    "_generator": {
      "name": "bicep",
      "version": "0.34.44.8038",
      "templateHash": "2313748121071500940"
    }
  },
  "parameters": {
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 90,
      "metadata": {
        "description": "The name of the resource group."
      }
    },
    "location": {
      "type": "string",
      "metadata": {
        "description": "The location resource group will be deployed."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.Resources/resourceGroups",
      "apiVersion": "2024-11-01",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "tags": {
        "environment": "production",
        "costCode": "349921"
      }
    }
  ]
}
```

## NOTES

This rule does not check if Resource Group names are unique.

## LINKS

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.resources/resourcegroups)
