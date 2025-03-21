---
severity: Important
pillar: Security
category: SE:08 Hardening resources
resource: Virtual Machine
resourceType: Microsoft.Compute/virtualMachines
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.PublicKey/
---

# VM password-based authentication is enabled

## SYNOPSIS

Linux virtual machines should use public keys.

## DESCRIPTION

Linux virtual machines should have password authentication disabled to help with eliminating password-based attacks.

## RECOMMENDATION

Consider disabling password-based authentication on Linux virtual machines and instead use public keys.

## EXAMPLES

### Configure with Azure template

To deploy virtual machines that pass this rule:

- Set the `properties.osProfile.linuxConfiguration.disablePasswordAuthentication` property to `true`.

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

To deploy virtual machines that pass this rule:

- Set the `properties.osProfile.linuxConfiguration.disablePasswordAuthentication` property to `true`.

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

## LINKS

- [SE:08 Hardening resources](https://learn.microsoft.com/azure/well-architected/security/harden-resources)
- [Azure security baseline for Linux Virtual Machines](https://learn.microsoft.com/security/benchmark/azure/baselines/virtual-machines-linux-security-baseline)
- [Detailed steps: Create and manage SSH keys for authentication to a Linux VM in Azure](https://learn.microsoft.com/azure/virtual-machines/linux/create-ssh-keys-detailed)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines)
