---
reviewed: 2024-01-05
severity: Important
pillar: Reliability
category: RE:01 Simplicity and efficiency
resource: Virtual Machine
resourceType: Microsoft.Compute/virtualMachines
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.UseManagedDisks/
---

# Use Managed Disks

## SYNOPSIS

Virtual machines (VMs) should use managed disks.

## DESCRIPTION

VMs can be configured with un-managed or managed disks.
Un-managed disks, are `.vhd` files stored on a Storage Account that you manage as files.
Managed disks are the successor to un-managed disks and improve durability and availability of VMs by the following:

- Are designed for 99.999% availability.
- Are replicated using Locally Redundant Storage or Zone Redundant Storage to improve durability.
- Are aligned to the fault domains of VM availability sets.
- Add support for availability zones to VM disk storage.

Additionally, managed disks provide the following benefits:

- Simplified management by allowing you to managed the VM disk as a Azure resource instead of a file.
- Improved security by providing granular access control using Azure Role-Based Access Control (RBAC).

## RECOMMENDATION

Consider using managed disks for virtual machine (VM) storage.

## EXAMPLES

### Configure with Azure template

To deploy VMs that pass this rule:

- For operating system (OS) disks:
  - To create a new OS disk:
    1. Set the `properties.storageProfile.osDisk.managedDisk.storageAccountType` property to valid storage type.
    2. Set the `properties.storageProfile.osDisk.createOption` property to `FromImage`.
  - To use an existing OS disk:
    1. Set the `properties.storageProfile.osDisk.createOption` property to `Attach`.
    2. Set the `properties.storageProfile.osDisk.managedDisk.id` property to the resource ID of an existing disk resource.
- For data disks:
  - To create a new data disk:
    1. Set the `properties.storageProfile.dataDisks[*].managedDisk.storageAccountType` property to valid storage type.
    2. Set the `properties.storageProfile.dataDisks[*].createOption` property to `Empty` or `FromImage`.
  - To use an existing data disk:
    1. Set the `properties.storageProfile.dataDisks[*].managedDisk.id` property to the resource ID of an existing disk resource.
    2. Set the `properties.storageProfile.dataDisks[*].createOption` property to `Attach`.

For example:

```json
{
  "type": "Microsoft.Compute/virtualMachines",
  "apiVersion": "2023-09-01",
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
      },
      "dataDisks": [
        {
          "createOption": "Attach",
          "lun": 0,
          "managedDisk": {
            "id": "[parameters('dataDiskId')]"
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
  "dependsOn": [
    "[resourceId('Microsoft.Network/networkInterfaces', parameters('nicName'))]"
  ]
}
```

### Configure with Bicep

To deploy VMs that pass this rule:

- For operating system (OS) disks:
  - To create a new OS disk:
    1. Set the `properties.storageProfile.osDisk.managedDisk.storageAccountType` property to valid storage type.
    2. Set the `properties.storageProfile.osDisk.createOption` property to `FromImage`.
  - To use an existing OS disk:
    1. Set the `properties.storageProfile.osDisk.createOption` property to `Attach`.
    2. Set the `properties.storageProfile.osDisk.managedDisk.id` property to the resource ID of an existing disk resource.
- For data disks:
  - To create a new data disk:
    1. Set the `properties.storageProfile.dataDisks[*].managedDisk.storageAccountType` property to valid storage type.
    2. Set the `properties.storageProfile.dataDisks[*].createOption` property to `Empty` or `FromImage`.
  - To use an existing data disk:
    1. Set the `properties.storageProfile.dataDisks[*].managedDisk.id` property to the resource ID of an existing disk resource.
    2. Set the `properties.storageProfile.dataDisks[*].createOption` property to `Attach`.

For example:

```bicep
resource vm 'Microsoft.Compute/virtualMachines@2023-09-01' = {
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
      dataDisks: [
        {
          createOption: 'Attach'
          lun: 0
          managedDisk: {
            id: dataDiskId
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
}
```

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Audit VMs that do not use managed disks](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Compute/VMRequireManagedDisk_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/06a78e20-9358-41c9-923c-fb736d382a4d`.

## LINKS

- [RE:01 Simplicity and efficiency](https://learn.microsoft.com/azure/well-architected/reliability/simplify)
- [Introduction to Azure managed disks](https://learn.microsoft.com/azure/virtual-machines/managed-disks-overview)
- [Reliability in Virtual Machines](https://learn.microsoft.com/azure/reliability/reliability-virtual-machines)
- [Using disks in Azure Resource Manager Templates](https://learn.microsoft.com/azure/virtual-machines/using-managed-disks-template-deployments)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines)
