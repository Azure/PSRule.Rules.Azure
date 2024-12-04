---
severity: Important
pillar: Security
category: SE:08 Hardening resources
resource: Virtual Machine Scale Sets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VMSS.PublicKey/
---

# VMSS password-based authentication is enabled

## SYNOPSIS

Use SSH keys instead of common credentials to secure virtual machine scale sets against malicious activities.

## DESCRIPTION

Linux virtual machine scale sets should have password authentication disabled to help with eliminating password-based attacks.

## RECOMMENDATION

Consider disabling password-based authentication on Linux VM scale sets and instead use public keys.

## EXAMPLES

### Configure with Azure template

To deploy an virtual machine scale set that pass this rule:

- Set the `properties.virtualMachineProfile.OsProfile.linuxConfiguration.disablePasswordAuthentication` property to `true`.

For example:

```json
{
  "type": "Microsoft.Compute/virtualMachineScaleSets",
  "apiVersion": "2024-07-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  },
  "sku": {
    "name": "Standard_D8d_v5",
    "tier": "Standard",
    "capacity": 3
  },
  "properties": {
    "overprovision": true,
    "upgradePolicy": {
      "mode": "Automatic"
    },
    "singlePlacementGroup": true,
    "virtualMachineProfile": {
      "storageProfile": {
        "osDisk": {
          "caching": "ReadWrite",
          "createOption": "FromImage"
        },
        "imageReference": {
          "publisher": "MicrosoftCblMariner",
          "offer": "Cbl-Mariner",
          "sku": "cbl-mariner-2-gen2",
          "version": "latest"
        }
      },
      "osProfile": {
        "adminUsername": "[parameters('adminUsername')]",
        "computerNamePrefix": "vmss-01",
        "linuxConfiguration": {
          "disablePasswordAuthentication": true,
          "provisionVMAgent": true,
          "ssh": {
            "publicKeys": [
              {
                "path": "/home/azureuser/.ssh/authorized_keys"
              }
            ]
          }
        }
      },
      "networkProfile": {
        "networkInterfaceConfigurations": [
          {
            "name": "vmss-001",
            "properties": {
              "primary": true,
              "enableAcceleratedNetworking": true,
              "ipConfigurations": [
                {
                  "name": "ipconfig1",
                  "properties": {
                    "primary": true,
                    "subnet": {
                      "id": "[parameters('subnetId')]"
                    },
                    "privateIPAddressVersion": "IPv4",
                    "loadBalancerBackendAddressPools": [
                      {
                        "id": "[parameters('backendPoolId')]"
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    }
  },
  "zones": [
    "1",
    "2",
    "3"
  ]
}
```

### Configure with Bicep

To deploy an virtual machine scale set that pass this rule:

- Set the `properties.virtualMachineProfile.OsProfile.linuxConfiguration.disablePasswordAuthentication` property to `true`.

For example:

```bicep
resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2024-07-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Standard_D8d_v5'
    tier: 'Standard'
    capacity: 3
  }
  properties: {
    overprovision: true
    upgradePolicy: {
      mode: 'Automatic'
    }
    singlePlacementGroup: true
    virtualMachineProfile: {
      storageProfile: {
        osDisk: {
          caching: 'ReadWrite'
          createOption: 'FromImage'
        }
        imageReference: {
          publisher: 'MicrosoftCblMariner'
          offer: 'Cbl-Mariner'
          sku: 'cbl-mariner-2-gen2'
          version: 'latest'
        }
      }
      osProfile: {
        adminUsername: adminUsername
        computerNamePrefix: 'vmss-01'
        linuxConfiguration: {
          disablePasswordAuthentication: true
          provisionVMAgent: true
          ssh: {
            publicKeys: [
              {
                path: '/home/azureuser/.ssh/authorized_keys'
              }
            ]
          }
        }
      }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'vmss-001'
            properties: {
              primary: true
              enableAcceleratedNetworking: true
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    primary: true
                    subnet: {
                      id: subnetId
                    }
                    privateIPAddressVersion: 'IPv4'
                    loadBalancerBackendAddressPools: [
                      {
                        id: backendPoolId
                      }
                    ]
                  }
                }
              ]
            }
          }
        ]
      }
    }
  }
  zones: [
    '1'
    '2'
    '3'
  ]
}
```

## LINKS

- [SE:08 Hardening resources](https://learn.microsoft.com/azure/well-architected/security/harden-resources)
- [Azure security baseline for Linux Virtual Machines](https://learn.microsoft.com/security/benchmark/azure/baselines/virtual-machines-linux-security-baseline)
- [Detailed steps: Create and manage SSH keys for authentication to a Linux VM in Azure](https://learn.microsoft.com/azure/virtual-machines/linux/create-ssh-keys-detailed)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachinescalesets)
