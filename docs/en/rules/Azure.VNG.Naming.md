---
reviewed: 2025-04-25
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Virtual Network Gateway
resourceType: Microsoft.Network/virtualNetworkGateways
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNG.Naming/
---

# Virtual Network Gateway must use standard naming

## SYNOPSIS

Virtual network gateway without a standard naming convention may be difficult to identify and manage.

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

For virtual network gateways, the Cloud Adoption Framework (CAF) recommends using the `vgw-` prefix.

Requirements for virtual network gateway names:

- At least 1 character, but no more than 80.
- Can include alphanumeric, underscore, hyphen, period characters.
- Can only start with a letter or number, and end with a letter, number or underscore.
- Virtual network gateway names must be unique within a resource group.

## RECOMMENDATION

Consider creating virtual network gateways with a standard name.
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

resource vng 'Microsoft.Network/virtualNetworkGateways@2024-05-01' = {
  name: name
  location: location
  properties: {
    gatewayType: 'Vpn'
    ipConfigurations: [
      {
        name: 'default'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
          publicIPAddress: {
            id: pipId
          }
        }
      }
    ]
    activeActive: true
    vpnType: 'RouteBased'
    vpnGatewayGeneration: 'Generation2'
    sku: {
      name: 'VpnGw1AZ'
      tier: 'VpnGw1AZ'
    }
  }
}
```

<!-- external:avm avm/res/network/virtual-network-gateway name -->

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
      "templateHash": "13056968664974712994"
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
        "description": "The resource ID for the subnet to connect to."
      }
    },
    "pipId": {
      "type": "string",
      "metadata": {
        "description": "The resource ID of the public IP address to use."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.Network/virtualNetworkGateways",
      "apiVersion": "2024-05-01",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "properties": {
        "gatewayType": "Vpn",
        "ipConfigurations": [
          {
            "name": "default",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "subnet": {
                "id": "[parameters('subnetId')]"
              },
              "publicIPAddress": {
                "id": "[parameters('pipId')]"
              }
            }
          }
        ],
        "activeActive": true,
        "vpnType": "RouteBased",
        "vpnGatewayGeneration": "Generation2",
        "sku": {
          "name": "VpnGw1AZ",
          "tier": "VpnGw1AZ"
        }
      }
    }
  ]
}
```

## NOTES

This rule does not check if virtual network gateway names are unique.

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_VIRTUAL_NETWORK_GATEWAY_NAME_FORMAT -->

To configure this rule set the `AZURE_VIRTUAL_NETWORK_GATEWAY_NAME_FORMAT` configuration value to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_VIRTUAL_NETWORK_GATEWAY_NAME_FORMAT: '^vgw-'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworkgateways)
