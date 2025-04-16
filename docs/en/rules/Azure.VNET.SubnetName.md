---
reviewed: 2023-09-10
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
resource: Virtual Network
resourceType: Microsoft.Network/virtualNetworks,Microsoft.Network/virtualNetworks/subnets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNET.SubnetName/
---

# Virtual Network Subnet name must be valid

## SYNOPSIS

Azure Resource Manager (ARM) has requirements for Virtual Network Subnet names.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Route table names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- Subnet names must be unique within a virtual network.

## RECOMMENDATION

Consider using names that meet subnet naming requirements.
Additionally consider naming resources with a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy virtual network subnets that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
@minLength(1)
@maxLength(80)
@description('The name of the resource.')
param name string

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2024-05-01' = {
  parent: vnet
  name: name
  properties: {
    addressPrefix: '10.0.0.0/24'
    networkSecurityGroup: {
      id: nsg.id
    }
    defaultOutboundAccess: false
  }
}
```

### Configure with Azure template

To deploy virtual network subnets that pass this rule:

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
      "templateHash": "1920943566989111543"
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
    }
  },
  "resources": [
    {
      "type": "Microsoft.Network/virtualNetworks/subnets",
      "apiVersion": "2024-05-01",
      "name": "[format('{0}/{1}', parameters('name'), parameters('name'))]",
      "properties": {
        "addressPrefix": "10.0.0.0/24",
        "networkSecurityGroup": {
          "id": "[resourceId('Microsoft.Network/networkSecurityGroups', parameters('name'))]"
        },
        "defaultOutboundAccess": false
      },
      "dependsOn": [
        "[resourceId('Microsoft.Network/networkSecurityGroups', parameters('name'))]",
        "[resourceId('Microsoft.Network/virtualNetworks', parameters('name'))]"
      ]
    }
  ]
}
```

## NOTES

This rule does not check if subnet names are unique.

## LINKS

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure deployment reference - Virtual Network](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks)
- [Azure deployment reference - Subnet](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks/subnets)
