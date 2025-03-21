---
severity: Important
pillar: Performance Efficiency
category: Design for performance
resource: Virtual Machine
resourceType: Microsoft.Compute/virtualMachines
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.SQLServerDisk/
---

# Configure Premium disks or above

## SYNOPSIS

Use Premium SSD disks or greater for data and log files for production SQL Server workloads.

## DESCRIPTION

Use premium SSD disks or greater for data and log files for production SQL Server workloads.

This is an advanced topic with many considerations, so we highly suggest to follow the `LINKS` section for more around this with aligned and up-to-date documentation.

## RECOMMENDATION

Configure Premium SSD disks or greater for data and log files for production SQL Server workloads.

## EXAMPLES

### Configure with Azure template

To deploy Virtual Machines that pass this rule:

- Set the `properties.storageProfile.osDisk.managedDisk.storageAccountType` property to `Premium_LRS` or greater.
- Configure each data disk included in `properties.storageProfile.dataDisks` to use `Premium_LRS` or greater by setting the property `managedDisk.storageAccountType`.

For example:

```json
{
  "type": "Microsoft.Compute/virtualMachines",
  "apiVersion": "2022-03-01",
  "name": "[parameters('virtualMachineName')]",
  "location": "[parameters('location')]",
  "properties": {
    "hardwareProfile": {
      "vmSize": "[parameters('virtualMachineSize')]"
    },
    "storageProfile": {
      "osDisk": {
        "createOption": "FromImage",
        "managedDisk": {
          "storageAccountType": "Premium_LRS"
        },
        "diskSizeGB": 127
      },
      "imageReference": {
        "publisher": "MicrosoftSQLServer",
        "offer": "SQL2019-WS2019",
        "sku": "Enterprise",
        "version": "latest"
      },
      "dataDisks": [
        {
          "lun": 0,
          "caching": "ReadOnly",
          "createOption": "Empty",
          "writeAcceleratorEnabled": false,
          "managedDisk": {
            "storageAccountType": "UltraSSD_LRS"
          },
          "diskSizeGB": 1023
        }
      ]
    },
    "networkProfile": {
      "networkInterfaces": [
        {
          "id": "[resourceId('Microsoft.Network/networkInterfaces', variables('networkInterfaceName'))]"
        }
      ]
    },
    "osProfile": {
      "computerName": "[parameters('virtualMachineName')]",
      "adminUsername": "[parameters('adminUsername')]",
      "adminPassword": "[parameters('adminPassword')]",
      "windowsConfiguration": {
        "enableAutomaticUpdates": true,
        "provisionVMAgent": true
      }
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.Network/networkInterfaces', variables('networkInterfaceName'))]"
  ]
}
```

### Configure with Bicep

To deploy Virtual Machines that pass this rule:

- Set the `properties.storageProfile.osDisk.managedDisk.storageAccountType` property to `Premium_LRS` or greater.
- Configure each data disk included in `properties.storageProfile.dataDisks` to use `Premium_LRS` or greater by setting the property `managedDisk.storageAccountType`.

For example:

```bicep
resource virtualMachine 'Microsoft.Compute/virtualMachines@2022-03-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Premium_LRS'
        }
        diskSizeGB: 127
      }
      imageReference: {
        publisher: 'MicrosoftSQLServer'
        offer: 'SQL2019-WS2019'
        sku: 'Enterprise'
        version: 'latest'
      }
      dataDisks: [
        {
          lun: 0
          caching: 'ReadOnly'
          createOption: 'Empty'
          writeAcceleratorEnabled: false
          managedDisk: {
            storageAccountType: 'UltraSSD_LRS'
          }
          diskSizeGB: 1023
        }
      ]
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface.id
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineName
      adminUsername: adminUsername
      adminPassword: adminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
  }
}
```

## NOTES

This rule is only applicable for OS disk and data disks configured with the property `properties.storageProfile.osDisk.managedDisk.storageAccountType` and the property `properties.storageProfile.dataDisks.managedDisk.storageAccountType`.

Resources declarations can therefore pass the rule which are using not using Premium disks or above.

## LINKS

- [Design for performance](https://learn.microsoft.com/azure/architecture/framework/scalability/design-checklist)
- [Performance best practices for SQL Server on Azure VMs](https://learn.microsoft.com/azure/azure-sql/virtual-machines/windows/performance-guidelines-best-practices-storage)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines)
