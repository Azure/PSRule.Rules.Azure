---
reviewed: 2025-04-25
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Virtual Machine
resourceType: Microsoft.Compute/virtualMachines
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.Naming/
---

# Virtual Machine must use standard naming

## SYNOPSIS

Virtual machines without a standard naming convention may be difficult to identify and manage.

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

For VMs, the Cloud Adoption Framework (CAF) recommends using the `vm` prefix.

Requirements for VM names:

- For Windows, at least 1 character, but no more than 15.
- For Linux, at least 1 character, but no more than 64.
- Can include alphanumeric and hyphen characters.
- Can only start with a letter or number, and end with a letter or number.
- VM names must be unique within a resource group.

## RECOMMENDATION

Consider creating VMs with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy virtual machines (VMs) that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

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

<!-- external:avm avm/res/compute/virtual-machine name -->

### Configure with Azure template

To deploy virtual machines (VMs) that pass this rule:

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

This rule does not check if VM names are unique.

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_VIRTUAL_MACHINE_NAME_FORMAT -->

To configure this rule set the `AZURE_VIRTUAL_MACHINE_NAME_FORMAT` configuration value to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_VIRTUAL_MACHINE_NAME_FORMAT: '^vm'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines)
