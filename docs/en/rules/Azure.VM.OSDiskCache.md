---
reviewed: 2026-03-25
severity: Important
pillar: Performance Efficiency
category: PE:08 Data performance
resource: Virtual Machine
resourceType: Microsoft.Compute/virtualMachines
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.OSDiskCache/
ms-content-id: d28da16e-4639-466f-95e5-4ab6bf61aec7
---

# Virtual Machine OS disk read write caching is not enabled

## SYNOPSIS

Operating system (OS) disk read/ write caching can improve virtual machines (VMs) performance.

## DESCRIPTION

Azure Virtual Machines (VMs) support caching for OS disks to improve performance.
The caching mode can be set to `ReadOnly`, `ReadWrite`, or `None`.
By default, the OS disks have `ReadWrite` caching enabled.

The appropriate caching mode depends on the specific workload configuration and performance requirements.
For most workloads `ReadWrite` caching provides improved performance and acceptable integrity of operating system files.
This is because operating system files and processes typically infrequently change and support flushing writes during changes.

In cases where workload data files are stored on the OS disk, `ReadWrite` caching may be inappropriate.
When designing high performance workloads, separate workload data files from the OS disk and use data disks.

## RECOMMENDATION

Consider enabling `ReadWrite` caching for OS disks to improve OS storage performance.

## EXAMPLES

### Configure with Bicep

To deploy VMs that pass this rule:

- Set the `properties.storageProfile.osDisk.caching` property to `ReadWrite`.

For example:

```bicep
resource linux 'Microsoft.Compute/virtualMachines@2025-04-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D8ds_v6'
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
        offer: 'azure-linux-3'
        sku: 'azure-linux-3-gen2'
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

### Configure with Azure template

To deploy VMs that pass this rule:

- Set the `properties.storageProfile.osDisk.caching` property to `ReadWrite`.

For example:

```json
{
  "type": "Microsoft.Compute/virtualMachines",
  "apiVersion": "2025-04-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "hardwareProfile": {
      "vmSize": "Standard_D8ds_v6"
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
        "offer": "azure-linux-3",
        "sku": "azure-linux-3-gen2",
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

## LINKS

- [PE:08 Data performance](https://learn.microsoft.com/azure/well-architected/performance-efficiency/optimize-data-performance)
- [Design for high performance](https://learn.microsoft.com/azure/virtual-machines/premium-storage-performance#disk-caching)
- [Virtual machine and disk performance](https://learn.microsoft.com/azure/virtual-machines/disks-performance)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines)
