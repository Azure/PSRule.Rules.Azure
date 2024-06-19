---
reviewed: 2022-07-09
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.Standalone/
---

# Standalone Virtual Machine

## SYNOPSIS

Use VM features to increase reliability and improve covered SLA for VM configurations.

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
- **Solid State Storage (SSD) Disks** - high performance block-level storage with three replicas of your data.

## RECOMMENDATION

Consider using availability zones/ sets or only premium/ ultra disks to improve SLA.

## EXAMPLES

### Configure with Azure template

To deploy VMs that pass this rule with on of the following:

- Deploy the VM in an Availability Set by specifying `properties.availabilitySet.id` in code.
- Deploy the VM in an Availability Zone by specifying `zones` with `1`, `2`, or `3` in code.
- Deploy the VM using only premium disks for OS and data disks by specifying `storageAccountType` as `Premium_LRS`.

For example:

```json
{
    "type": "Microsoft.Compute/virtualMachines",
    "apiVersion": "2022-03-01",
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
                    "id": "[resourceId('Microsoft.Network/networkInterfaces', format('{0}-nic0', parameters('name')))]"
                }
            ]
        }
    },
    "dependsOn": [
        "[resourceId('Microsoft.Network/networkInterfaces', format('{0}-nic0', parameters('name')))]"
    ]
}
```

### Configure with Bicep

To deploy VMs that pass this rule with on of the following:

- Deploy the VM in an Availability Set by specifying `properties.availabilitySet.id` in code.
- Deploy the VM in an Availability Zone by specifying `zones` with `1`, `2`, or `3` in code.
- Deploy the VM using only premium disks for OS and data disks by specifying `storageAccountType` as `Premium_LRS`.

For example:

```bicep
resource vm1 'Microsoft.Compute/virtualMachines@2022-03-01' = {
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

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Virtual Machine SLA](https://azure.microsoft.com/support/legal/sla/virtual-machines)
- [Availability options for virtual machines in Azure](https://learn.microsoft.com/azure/virtual-machines/availability)
- [Manage the availability of Windows virtual machines in Azure](https://learn.microsoft.com/azure/virtual-machines/windows/manage-availability)
- [Manage the availability of Linux virtual machines](https://learn.microsoft.com/azure/virtual-machines/linux/manage-availability)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines)
