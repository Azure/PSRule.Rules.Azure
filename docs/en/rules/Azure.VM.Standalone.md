---
reviewed: 2025-02-27
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Virtual Machine
resourceType: Microsoft.Compute/virtualMachines
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.Standalone/
---

# Virtual Machine is not configured for improved SLA

## SYNOPSIS

Single instance VMs are a single point of failure, however reliability can be improved by using premium storage.

## DESCRIPTION

All VM configurations within Azure offer an SLA.
However, the SLA provided and the overall availability of the system varies depending on the configuration.

First, consider performing a Failure Mode Analysis (FMA) of the system.
A FMA is the process of analyzing the system to determine the possible failure points.

For Virtual Machines (VMs), running a single instance is often a single point of failure.
In many but not all cases, the number of VMs can be increased to add redundancy to the system.
Taking advantage of some of the features of Azure can further increase the availability of the system.

- **Availability Zones (AZ)** - is a physically separate zone, within an Azure region.
  Each Availability Zone has a distinct power source, network, and cooling.
- **Availability Sets** - is a logical grouping of VMs that allows Azure to understand how your application is built.
  By understanding the distinct tiers of the application, Azure can better organize compute and storage to improve availability.
- **Premium Solid State Storage (SSD) Disks** - high performance block-level storage with three replicas of your data.
  When you use a mix of storage for OS and data disk attached to your VMs, the SLA is based on the lowest performing disk.

## RECOMMENDATION

Consider using availability zones/ sets or only premium/ ultra disks to improve SLA.

## EXAMPLES

### Configure with Bicep

To deploy VMs that pass this rule with on of the following:

- Deploy the VM in an Availability Set by specifying `properties.availabilitySet.id` in code.
- Deploy the VM in an Availability Zone by specifying `zones` with `1`, `2`, or `3` in code.
- Deploy the VM using only premium disks for OS and data disks by specifying `storageAccountType` as `Premium_LRS`.

For example:

```bicep
resource vm 'Microsoft.Compute/virtualMachines@2024-07-01' = {
  name: name
  location: location
  zones: [
    '1'
  ]
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    osProfile: {
      computerName: name
      adminUsername: adminUsername
      adminPassword: adminPassword
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
    }
    licenseType: 'Windows_Server'
    networkProfile: {
      networkInterfaces: [
        {
          id: nic.id
        }
      ]
    }
  }
}
```

<!-- external:avm avm/res/compute/virtual-machine zone -->

### Configure with Azure template

To deploy VMs that pass this rule with on of the following:

- Deploy the VM in an Availability Set by specifying `properties.availabilitySet.id` in code.
- Deploy the VM in an Availability Zone by specifying `zones` with `1`, `2`, or `3` in code.
- Deploy the VM using only premium disks for OS and data disks by specifying `storageAccountType` as `Premium_LRS`.

For example:

```json
{
  "type": "Microsoft.Compute/virtualMachines",
  "apiVersion": "2024-07-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "zones": [
    "1"
  ],
  "properties": {
    "hardwareProfile": {
      "vmSize": "Standard_D2s_v3"
    },
    "osProfile": {
      "computerName": "[parameters('name')]",
      "adminUsername": "[parameters('adminUsername')]",
      "adminPassword": "[parameters('adminPassword')]"
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
      }
    },
    "licenseType": "Windows_Server",
    "networkProfile": {
      "networkInterfaces": [
        {
          "id": "[resourceId('Microsoft.Network/networkInterfaces', parameters('nicName'))]"
        }
      ]
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.Network/networkInterfaces', parameters('nicName'))]"
  ]
}
```

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Virtual Machine SLA](https://www.microsoft.com/licensing/docs/view/Service-Level-Agreements-SLA-for-Online-Services)
- [Availability options for Azure Virtual Machines](https://learn.microsoft.com/azure/virtual-machines/availability)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines)
