---
reviewed: 2026-03-26
severity: Important
pillar: Security
category: SE:08 Hardening resources
resource: Azure Fleet
resourceType: Microsoft.AzureFleet/fleets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Fleet.PublicKey/
---

# Azure Fleet password-based authentication is enabled

## SYNOPSIS

Use SSH keys instead of common credentials to secure Linux Azure Fleet VMs against malicious activities.

## DESCRIPTION

Linux Azure Fleet virtual machine profiles should have password authentication disabled to help with eliminating password-based attacks.

## RECOMMENDATION

Consider disabling password-based authentication on Linux Azure Fleet VM profiles and instead use public keys.

## EXAMPLES

### Configure with Bicep

To deploy an Azure Fleet that passes this rule:

- Set the `properties.computeProfile.baseVirtualMachineProfile.osProfile.linuxConfiguration.disablePasswordAuthentication` property to `true`.

For example:

```bicep
resource linux_fleet 'Microsoft.AzureFleet/fleets@2024-11-01' = {
  name: name
  location: location
  properties: {
    computeProfile: {
      baseVirtualMachineProfile: {
        osProfile: {
          computerNamePrefix: 'fleet'
          adminUsername: adminUsername
          linuxConfiguration: {
            disablePasswordAuthentication: true
            provisionVMAgent: true
            ssh: {
              publicKeys: [
                {
                  path: '/home/azureuser/.ssh/authorized_keys'
                  keyData: sshPublicKey
                }
              ]
            }
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
            createOption: 'FromImage'
            caching: 'ReadWrite'
            managedDisk: {
              storageAccountType: 'Premium_LRS'
            }
          }
        }
        networkProfile: {
          networkInterfaceConfigurations: [
            {
              name: 'netconfig'
              properties: {
                ipConfigurations: [
                  {
                    name: 'ipconfig'
                    properties: {
                      primary: true
                      subnet: {
                        id: subnetId
                      }
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    }
    vmSizesProfile: [
      {
        name: 'Standard_D8ds_v6'
        rank: 0
      }
    ]
    regularPriorityProfile: {
      minCapacity: 1
      capacity: 5
      allocationStrategy: 'Prioritized'
    }
  }
}
```

### Configure with Azure template

To deploy an Azure Fleet that passes this rule:

- Set the `properties.computeProfile.baseVirtualMachineProfile.osProfile.linuxConfiguration.disablePasswordAuthentication` property to `true`.

For example:

```json
{
  "type": "Microsoft.AzureFleet/fleets",
  "apiVersion": "2024-11-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "computeProfile": {
      "baseVirtualMachineProfile": {
        "osProfile": {
          "computerNamePrefix": "fleet",
          "adminUsername": "[parameters('adminUsername')]",
          "linuxConfiguration": {
            "disablePasswordAuthentication": true,
            "provisionVMAgent": true,
            "ssh": {
              "publicKeys": [
                {
                  "path": "/home/azureuser/.ssh/authorized_keys",
                  "keyData": "[parameters('sshPublicKey')]"
                }
              ]
            }
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
            "createOption": "FromImage",
            "caching": "ReadWrite",
            "managedDisk": {
              "storageAccountType": "Premium_LRS"
            }
          }
        },
        "networkProfile": {
          "networkInterfaceConfigurations": [
            {
              "name": "netconfig",
              "properties": {
                "ipConfigurations": [
                  {
                    "name": "ipconfig",
                    "properties": {
                      "primary": true,
                      "subnet": {
                        "id": "[parameters('subnetId')]"
                      }
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    },
    "vmSizesProfile": [
      {
        "name": "Standard_D8ds_v6",
        "rank": 0
      }
    ],
    "regularPriorityProfile": {
      "minCapacity": 1,
      "capacity": 5,
      "allocationStrategy": "Prioritized"
    }
  }
}
```

## LINKS

- [SE:08 Hardening resources](https://learn.microsoft.com/azure/well-architected/security/harden-resources)
- [Azure security baseline for Linux Virtual Machines](https://learn.microsoft.com/security/benchmark/azure/baselines/virtual-machines-linux-virtual-machines-security-baseline)
- [Detailed steps: Create and manage SSH keys for authentication to a Linux VM in Azure](https://learn.microsoft.com/azure/virtual-machines/linux/create-ssh-keys-detailed)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.azurefleet/fleets)
