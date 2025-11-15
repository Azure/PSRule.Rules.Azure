---
reviewed: 2025-10-25
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
resource: Load Balancer
resourceType: Microsoft.Network/loadBalancers
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.LB.Name/
---

# Use valid Load Balancer names

## SYNOPSIS

Load Balancer names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Load Balancer names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- Load Balancer names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Load Balancer naming requirements.
Additionally consider naming resources with a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy load balancers that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
@minLength(1)
@maxLength(80)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

resource internal_lb 'Microsoft.Network/loadBalancers@2024-05-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'frontendIPConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
        zones: [
          '1'
          '2'
          '3'
        ]
      }
    ]
  }
}
```

<!-- external:avm avm/res/network/load-balancer name -->

### Configure with Azure template

To deploy load balancers that pass this rule:

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
      "minLength": 1,
      "maxLength": 80,
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
      "type": "Microsoft.Network/loadBalancers",
      "apiVersion": "2024-05-01",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "Standard",
        "tier": "Regional"
      },
      "properties": {
        "frontendIPConfigurations": [
          {
            "name": "frontendIPConfig",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "subnet": {
                "id": "[parameters('subnetId')]"
              }
            },
            "zones": [
              "1",
              "2",
              "3"
            ]
          }
        ]
      }
    }
  ]
}
```

## NOTES

This rule does not check if Load Balancer names are unique.

## LINKS

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Operational Excellence: Level 2](https://learn.microsoft.com/azure/well-architected/operational-excellence/maturity-model?tabs=level2)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/loadbalancers)
