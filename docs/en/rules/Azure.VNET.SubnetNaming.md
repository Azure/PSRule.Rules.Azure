---
reviewed: 2025-08-23
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Virtual Network
resourceType: Microsoft.Network/virtualNetworks,Microsoft.Network/virtualNetworks/subnets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNET.SubnetNaming/
---

# Virtual Network Subnet must use standard naming

## SYNOPSIS

Virtual Network subnets without a standard naming convention may be difficult to identify and manage.

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

For subnets, the Cloud Adoption Framework (CAF) recommends using the `snet-` prefix.

Requirements for subnet names:

- At least 1 characters, but no more than 80.
- Can include alphanumeric, underscore, hyphen, period characters.
- Can only start with a letter or number, and end with a letter, number or underscore.
- VNET names must be unique within the parent VNET.

## RECOMMENDATION

Consider creating subnets with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

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

<!-- external:avm avm/res/network/virtual-network/subnet name -->

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

This rule does not check if subnets names are unique and ignores the following subnets which are predefined by Azure:

- GatewaySubnet
- AzureBastionSubnet
- AzureFirewallSubnet
- AzureFirewallManagementSubnet
- RouteServerSubnet

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_VNET_SUBNET_NAME_FORMAT -->

To configure this rule set the `AZURE_VNET_SUBNET_NAME_FORMAT` configuration value to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_VNET_SUBNET_NAME_FORMAT: '^snet-'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure deployment reference - Virtual Network](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks)
- [Azure deployment reference - Subnet](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks/subnets)
