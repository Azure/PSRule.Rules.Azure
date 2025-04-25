---
reviewed: 2025-04-25
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Virtual Network
resourceType: Microsoft.Network/virtualNetworks
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNET.Naming/
---

# Virtual Network must use standard naming

## SYNOPSIS

Virtual Networks without a standard naming convention may be difficult to identify and manage.

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

For virtual networks, the Cloud Adoption Framework (CAF) recommends using the `vnet-` prefix.

Requirements for virtual network names:

- At least 2 characters, but no more than 64.
- Can include alphanumeric, underscore, hyphen, period characters.
- Can only start with a letter or number, and end with a letter, number or underscore.
- VNET names must be unique within a resource group.

## RECOMMENDATION

Consider creating virtual networks with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

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

This rule does not check if virtual network names are unique.

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_VNET_NAME_FORMAT -->

To configure this rule set the `AZURE_VNET_NAME_FORMAT` configuration value to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_VNET_NAME_FORMAT: '^vnet-'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks)
