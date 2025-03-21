---
reviewed: 2023-12-07
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
resource: Network Interface
resourceType: Microsoft.Network/networkInterfaces
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.NIC.Name/
---

# Use valid NIC names

## SYNOPSIS

Network Interface (NIC) names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for Network Interface names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- NIC names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Network Interface naming requirements.
Additionally consider naming resources with a standard naming convention.

## EXAMPLES

### Configure with Azure template

To deploy network interfaces that pass this rule:

- Configuring a `minLength` and `maxLength` constraint for the resource name parameter.
- Optionally, you could also use a `uniqueString()` function to generate a unique name.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
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
        "description": "A reference to the VNET subnet where the VM will be deployed."
      }
    },
    "nicName": {
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
      "type": "Microsoft.Network/networkInterfaces",
      "apiVersion": "2023-05-01",
      "name": "[parameters('nicName')]",
      "location": "[parameters('location')]",
      "properties": {
        "ipConfigurations": [
          {
            "name": "ipconfig-1",
            "properties": {
              "privateIPAllocationMethod": "Dynamic",
              "subnet": {
                "id": "[parameters('subnetId')]"
              }
            }
          }
        ]
      }
    }
  ]
}
```

### Configure with Bicep

To deploy network interfaces that pass this rule:

- Configuring a `minLength` and `maxLength` constraint for the resource name parameter.
- Optionally, you could also use a `uniqueString()` function to generate a unique name.

For example:

```bicep
@minLength(1)
@maxLength(80)
@sys.description('The name of the resource.')
param nicName string

resource nic 'Microsoft.Network/networkInterfaces@2023-05-01' = {
  name: nicName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig-1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: subnetId
          }
        }
      }
    ]
  }
}
```

## NOTES

This rule does not check if Network Interface names are unique.

## LINKS

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Design review checklist for Operational Excellence](https://learn.microsoft.com/azure/well-architected/operational-excellence/checklist)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/networkinterfaces)
