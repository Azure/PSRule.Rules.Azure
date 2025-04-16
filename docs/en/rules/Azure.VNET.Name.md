---
reviewed: 2023-12-01
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
resource: Virtual Network
resourceType: Microsoft.Network/virtualNetworks
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNET.Name/
---

# Virtual Network name must be valid

## SYNOPSIS

Azure Resource Manager (ARM) has requirements for Virtual Network names.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Virtual Network names are:

- Between 2 and 64 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- VNET names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Virtual Network naming requirements.
Additionally consider naming resources with a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy virtual networks that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
@minLength(2)
@maxLength(64)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

// An example virtual network (VNET) with NSG configured.
resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    dhcpOptions: {
      dnsServers: [
        '10.0.1.4'
        '10.0.1.5'
      ]
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
      {
        name: 'snet-001'
        properties: {
          addressPrefix: '10.0.1.0/24'
          networkSecurityGroup: {
            id: nsg.id
          }
        }
      }
      {
        name: 'snet-002'
        properties: {
          addressPrefix: '10.0.2.0/24'
          delegations: [
            {
              name: 'HSM'
              properties: {
                serviceName: 'Microsoft.HardwareSecurityModules/dedicatedHSMs'
              }
            }
          ]
        }
      }
    ]
  }
}
```

<!-- external:avm avm/res/network/virtual-network name -->

### Configure with Azure template

To deploy virtual networks that pass this rule:

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
      "templateHash": "4612577866627056405"
    }
  },
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
      "type": "Microsoft.Network/virtualNetworks",
      "apiVersion": "2024-05-01",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "properties": {
        "addressSpace": {
          "addressPrefixes": [
            "10.0.0.0/16"
          ]
        },
        "dhcpOptions": {
          "dnsServers": [
            "10.0.1.4",
            "10.0.1.5"
          ]
        },
        "subnets": [
          {
            "name": "GatewaySubnet",
            "properties": {
              "addressPrefix": "10.0.0.0/24"
            }
          },
          {
            "name": "snet-001",
            "properties": {
              "addressPrefix": "10.0.1.0/24",
              "networkSecurityGroup": {
                "id": "[resourceId('Microsoft.Network/networkSecurityGroups', parameters('name'))]"
              }
            }
          },
          {
            "name": "snet-002",
            "properties": {
              "addressPrefix": "10.0.2.0/24",
              "delegations": [
                {
                  "name": "HSM",
                  "properties": {
                    "serviceName": "Microsoft.HardwareSecurityModules/dedicatedHSMs"
                  }
                }
              ]
            }
          }
        ]
      },
      "dependsOn": [
        "[resourceId('Microsoft.Network/networkSecurityGroups', parameters('name'))]"
      ]
    }
  ]
}
```

## NOTES

This rule does not check if Virtual Network names are unique.

## LINKS

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks)
