---
severity: Important
pillar: Operational Excellence
category: OE:10 Automation design
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.Agent/
ms-content-id: e4f6f6e7-593c-4507-811d-778ee8ec9ac4
---

# Virtual Machine agent is not provisioned

## SYNOPSIS

Virtual Machines (VMs) without an agent provisioned are unable to use monitoring, management, and security extensions.

## DESCRIPTION

The virtual machine (VM) agent is required for most functionality that interacts with the guest operating system.
This includes any VMs extensions such as Azure monitoring, management, and security features.

Extensions help reduce management overhead by providing an entry point to bootstrap VM monitoring and configuration.

By default, the VM agent is provisioned for all supported operating systems.

## RECOMMENDATION

Consider automatically provisioning the VM agent for all supported operating systems to reduce management overhead of VMs.

## EXAMPLES

### Configure with Azure template

To deploy VMs that pass this rule:

- Set the `properties.osProfile.linuxConfiguration.provisionVMAgent` property to `true` for Linux VMs.
- Set the `properties.osProfile.windowsConfiguration.provisionVMAgent` property to `true` for Windows VMs.

For example:

```json
{
  "type": "Microsoft.Compute/virtualMachines",
  "apiVersion": "2024-03-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "hardwareProfile": {
      "vmSize": "Standard_D8d_v5"
    },
    "osProfile": {
      "computerName": "[parameters('name')]",
      "adminUsername": "[parameters('adminUsername')]",
      "linuxConfiguration": {
        "provisionVMAgent": true,
        "disablePasswordAuthentication": true
      }
    },
    "storageProfile": {
      "imageReference": {
        "publisher": "MicrosoftCblMariner",
        "offer": "Cbl-Mariner",
        "sku": "cbl-mariner-2-gen2",
        "version": "latest"
      },
      "osDisk": {
        "name": "[format('{0}-disk0', parameters('name'))]",
        "caching": "ReadWrite",
        "createOption": "FromImage",
        "managedDisk": {
          "storageAccountType": "Premium_LRS"
        }
      }
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
    "[resourceId('Microsoft.Network/networkInterfaces', parameters('nicName'))]"
  ]
}
```

### Configure with Bicep

To deploy VMs that pass this rule:

- Set the `properties.osProfile.linuxConfiguration.provisionVMAgent` property to `true` for Linux VMs.
- Set the `properties.osProfile.windowsConfiguration.provisionVMAgent` property to `true` for Windows VMs.

For example:

```bicep
resource linux 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D8d_v5'
    }
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      linuxConfiguration: {
        provisionVMAgent: true
        disablePasswordAuthentication: true
      }
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftCblMariner'
        offer: 'Cbl-Mariner'
        sku: 'cbl-mariner-2-gen2'
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

## NOTES

In general provisioning the VM agent is recommended for all supported operating systems.
For network virtual appliances (NVAs) or specialized unsupported OS images installed from the Azure Marketplace,
the VM agent may be disabled by the publisher.

## LINKS

- [OE:10 Automation design](https://learn.microsoft.com/azure/well-architected/operational-excellence/enable-automation)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines)
