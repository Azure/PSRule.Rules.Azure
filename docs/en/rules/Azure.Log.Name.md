---
reviewed: 2025-05-25
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
resource: Azure Monitor Logs
resourceType: Microsoft.OperationalInsights/workspaces
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Log.Name/
---

# Log workspace name must be valid

## SYNOPSIS

Azure Resource Manager (ARM) has requirements for Azure Monitor Log workspace names.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Azure Monitor Log workspace names are:

- Between 3 and 63 characters long.
- Letters, numbers, and hyphens.
- Must start and end with a letter or number.
- Resource names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Azure Monitor log workspaces naming requirements.
Additionally consider naming resources with a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy workspaces that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
@minLength(4)
@maxLength(63)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

param secondaryLocation string

// An example Log Analytics workspace with replication enabled.
resource workspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: name
  location: location
  properties: {
    replication: {
      enabled: true
      location: secondaryLocation
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: 30
    features: {
      disableLocalAuth: true
    }
    sku: {
      name: 'PerGB2018'
    }
  }
}
```

<!-- external:avm avm/res/operational-insights/workspace name -->

### Configure with Azure template

To deploy workspaces that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "name": {
      "type": "string",
      "minLength": 4,
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
    },
    "secondaryLocation": {
      "type": "string"
    }
  },
  "resources": [
    {
      "type": "Microsoft.OperationalInsights/workspaces",
      "apiVersion": "2025-02-01",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "properties": {
        "replication": {
          "enabled": true,
          "location": "[parameters('secondaryLocation')]"
        },
        "publicNetworkAccessForIngestion": "Enabled",
        "publicNetworkAccessForQuery": "Enabled",
        "retentionInDays": 30,
        "features": {
          "disableLocalAuth": true
        },
        "sku": {
          "name": "PerGB2018"
        }
      }
    }
  ]
}
```

## NOTES

This rule does not check if workspace names are unique.

## LINKS

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.operationalinsights/workspaces)
