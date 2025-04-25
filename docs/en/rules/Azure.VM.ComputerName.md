---
severity: Awareness
pillar: Operational Excellence
category: OE:04 Continuous integration
resource: Virtual Machine
resourceType: Microsoft.Compute/virtualMachines
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.ComputerName/
---

# Use valid VM computer names

## SYNOPSIS

Virtual Machine (VM) computer name should meet naming requirements.

## DESCRIPTION

When configuring Azure VMs the assigned computer name must meet operation system (OS) requirements.

The requirements for Windows VMs are:

- Between 1 and 15 characters long.
- Alphanumerics, and hyphens.
- Can not include only numbers.

The requirements for Linux VMs are:

- Between 1 and 64 characters long.
- Alphanumerics, periods, and hyphens.
- Start with alphanumeric.

## RECOMMENDATION

Consider using computer names that meet OS naming requirements.
Additionally, consider using computer names that match the VM resource name.

## EXAMPLES

### Configure with Bicep

To deploy virtual machines (VMs) that pass this rule:

- Set the `properties.osProfile.computerName` property to a string that matches the naming requirements.

For example:

```bicep
@minLength(1)
@maxLength(15)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

@secure()
@description('The name of the local administrator account.')
param adminUsername string

@secure()
@description('A password for the local administrator account.')
param adminPassword string

@description('The VM sku to use.')
param sku string

resource vm 'Microsoft.Compute/virtualMachines@2024-11-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        provisionVMAgent: true
      }
    }
    securityProfile: {
      securityType: 'TrustedLaunch'
      encryptionAtHost: true
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: sku
        version: 'latest'
      }
      osDisk: {
        name: '${name}-disk0'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
      }
      dataDisks: [
        {
          createOption: 'Attach'
          lun: 0
          managedDisk: {
            id: dataDisk.id
          }
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
  zones: [
    '1'
  ]
}
```

<!-- external:avm avm/res/compute/virtual-machine computerName -->

### Configure with Azure template

To deploy virtual machines (VMs) that pass this rule:

- Set the `properties.osProfile.computerName` property to a string that matches the naming requirements.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "metadata": {
    "_generator": {
      "name": "bicep",
      "version": "0.34.44.8038",
      "templateHash": "18140604143517495412"
    }
  },
  "parameters": {
    "name": {
      "type": "string",
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
    "adminUsername": {
      "type": "securestring",
      "metadata": {
        "description": "The name of the local administrator account."
      }
    },
    "adminPassword": {
      "type": "securestring",
      "metadata": {
        "description": "A password for the local administrator account."
      }
    },
    "sku": {
      "type": "string",
      "metadata": {
        "description": "The VM sku to use."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.Compute/virtualMachines",
      "apiVersion": "2024-11-01",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "identity": {
        "type": "SystemAssigned"
      },
      "properties": {
        "hardwareProfile": {
          "vmSize": "Standard_D2s_v3"
        },
        "osProfile": {
          "computerName": "[parameters('name')]",
          "adminUsername": "[parameters('adminUsername')]",
          "adminPassword": "[parameters('adminPassword')]",
          "windowsConfiguration": {
            "provisionVMAgent": true
          }
        },
        "securityProfile": {
          "securityType": "TrustedLaunch",
          "encryptionAtHost": true,
          "uefiSettings": {
            "secureBootEnabled": true,
            "vTpmEnabled": true
          }
        },
        "storageProfile": {
          "imageReference": {
            "publisher": "MicrosoftWindowsServer",
            "offer": "WindowsServer",
            "sku": "[parameters('sku')]",
            "version": "latest"
          },
          "osDisk": {
            "name": "[format('{0}-disk0', parameters('name'))]",
            "caching": "ReadWrite",
            "createOption": "FromImage",
            "managedDisk": {
              "storageAccountType": "Premium_LRS"
            }
          },
          "dataDisks": [
            {
              "createOption": "Attach",
              "lun": 0,
              "managedDisk": {
                "id": "[resourceId('Microsoft.Compute/disks', parameters('name'))]"
              }
            }
          ]
        },
        "networkProfile": {
          "networkInterfaces": [
            {
              "id": "[resourceId('Microsoft.Network/networkInterfaces', parameters('nicName'))]"
            }
          ]
        }
      },
      "zones": [
        "1"
      ],
      "dependsOn": [
        "[resourceId('Microsoft.Compute/disks', parameters('name'))]",
        "[resourceId('Microsoft.Network/networkInterfaces', parameters('nicName'))]"
      ]
    }
  ]
}
```

## NOTES

VM resource names have different naming restrictions.
See `Azure.VM.Name` for details.

## LINKS

- [OE:04 Continuous integration](https://learn.microsoft.com/azure/well-architected/operational-excellence/release-engineering-continuous-integration)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines)
