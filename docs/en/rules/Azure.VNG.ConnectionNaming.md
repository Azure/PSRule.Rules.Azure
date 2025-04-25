---
reviewed: 2025-04-25
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Virtual Network Gateway
resourceType: Microsoft.Network/virtualNetworkGateways/connections
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNG.ConnectionNaming/
---

# Virtual Network Gateway Connection must use standard naming

## SYNOPSIS

Virtual network gateway connections without a standard naming convention may be difficult to identify and manage.

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

For virtual network gateway connections, the Cloud Adoption Framework (CAF) recommends using the `cn-` prefix.

Requirements for virtual network gateway connection names:

- At least 1 character, but no more than 80.
- Can include alphanumeric, underscore, hyphen, period characters.
- Can only start with a letter or number, and end with a letter, number or underscore.
- Connection names must be unique within a resource group.

## RECOMMENDATION

Consider creating virtual network gateway connections with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy Virtual Network Gateways that pass this rule:

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

resource connection 'Microsoft.Network/connections@2024-05-01' = {
  name: name
  location: location
  properties: {
    connectionType: 'ExpressRoute'
    routingWeight: 0
    virtualNetworkGateway1: {
      id: vng.id
    }
    peer: {
      id: circuitId
    }
  }
}
```

<!-- external:avm avm/res/network/connection name -->

### Configure with Azure template

To deploy Virtual Network Gateways that pass this rule:

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
      "templateHash": "3784629056340702957"
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
    "circuitId": {
      "type": "string",
      "metadata": {
        "description": "The resource ID of the ExpressRoute circuit to connect to."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.Network/connections",
      "apiVersion": "2024-05-01",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "properties": {
        "connectionType": "ExpressRoute",
        "routingWeight": 0,
        "virtualNetworkGateway1": {
          "id": "[resourceId('Microsoft.Network/virtualNetworkGateways', parameters('name'))]"
        },
        "peer": {
          "id": "[parameters('circuitId')]"
        }
      },
      "dependsOn": [
        "[resourceId('Microsoft.Network/virtualNetworkGateways', parameters('name'))]"
      ]
    }
  ]
}
```

## NOTES

This rule does not check if virtual network gateway connection names are unique.

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_GATEWAY_CONNECTION_NAME_FORMAT -->

To configure this rule set the `AZURE_GATEWAY_CONNECTION_NAME_FORMAT` configuration value to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_GATEWAY_CONNECTION_NAME_FORMAT: '^cn-'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/connections)
