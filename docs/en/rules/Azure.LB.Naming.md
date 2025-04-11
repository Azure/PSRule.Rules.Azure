---
reviewed: 2025-04-11
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Load Balancer
resourceType: Microsoft.Network/loadBalancers
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.LB.Naming/
---

# Use standard load balancer names

## SYNOPSIS

Load balancer names should use a standard prefix.

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

For load balancers, the Cloud Adoption Framework (CAF) recommends using the `lbi-`, and `lbe-` prefix.
Use of different prefixes depends on the intended usage of the load balancer.

Requirements for load balancers names:

- At least 1 character, but no more than 80.
- Can include alphanumeric, underscore, hyphen, period characters.
- Can only start with a letter or number, and end with a letter, number or underscore.
- Load balancer names must be unique within a resource group.

## RECOMMENDATION

Consider creating load balancers with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

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
  "metadata": {
    "_generator": {
      "name": "bicep",
      "version": "0.34.44.8038",
      "templateHash": "15799925094518670850"
    }
  },
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
    },
    "subnetId": {
      "type": "string",
      "metadata": {
        "description": "The resource ID of the virtual network subnet."
      }
    },
    "pipId": {
      "type": "string",
      "metadata": {
        "description": "The resource ID of the public IP address."
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

This rule does not check if load balancer names are unique.
Additionally, the following naming conventions that are related to managed resources are ignored:

- `kubernetes*`

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_LOAD_BALANCER_NAME_FORMAT -->

To configure this rule set the `AZURE_LOAD_BALANCER_NAME_FORMAT` configuration value to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_LOAD_BALANCER_NAME_FORMAT: '^(lbi|lbe)-'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/loadbalancers)
