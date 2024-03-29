---
severity: Important
pillar: Security
category: Identity and access management
resource: Virtual Machine Scale Sets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VMSS.PublicKey/
---

# Disable password authentication

## SYNOPSIS

Use SSH keys instead of common credentials to secure virtual machine scale sets against malicious activities.

## DESCRIPTION

Linux virtual machine scale sets should have password authentication disabled to help with eliminating password-based attacks.

A common tactic observed used by adversaries against customers running Linux Virtual Machines (VMs) in Azure is password-based attacks.

## RECOMMENDATION

Linux virtual machine scale sets should have password authentication disabled and instead use SSH keys.

## EXAMPLES

### Configure with Azure template

To deploy an virtual machine scale set that pass this rule:

- Set `properties.virtualMachineProfile.OsProfile.linuxConfiguration.disablePasswordAuthentication` to `true`.

For example:

```json
{
    "type": "Microsoft.Compute/virtualMachineScaleSets",
    "apiVersion": "2021-11-01",
    "name": "vmss-01",
    "location": "[resourceGroup().location]",
    "sku": {
      "name": "b2ms",
      "tier": "Standard",
      "capacity": 1
    },
    "properties": {
      "overprovision": true,
      "upgradePolicy": {
        "mode": "Automatic"
      },
      "singlePlacementGroup": true,
      "platformFaultDomainCount": 3,
      "virtualMachineProfile": {
        "storageProfile": {
          "osDisk": {
            "caching": "ReadWrite",
            "createOption": "FromImage"
          },
          "imageReference": {
            "publisher": "microsoft-aks",
            "offer": "aks",
            "sku": "aks-ubuntu-1804-202208",
            "version": "2022.08.29"
          }
        },
        "osProfile": {
          "adminUsername": "azureuser",
          "computerNamePrefix": "vmss-01",
          "linuxConfiguration": {
            "disablePasswordAuthentication": true
          },
          "provisionVMAgent": true,
          "ssh": {
            "publicKeys": [
              {
                "path": "/home/azureuser/.ssh/authorized_keys"
              }
            ]
          }
        },
        "networkProfile": {
          "networkInterfaceConfigurations": [
            {
              "name": "vmss-001",
              "properties": {
                "primary": true,
                "enableAcceleratedNetworking": true,
                "networkSecurityGroup": {
                  "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkSecurityGroups/nsg-001"
                },
                "ipConfigurations": [
                  {
                    "name": "ipconfig1",
                    "properties": {
                      "primary": true,
                      "subnet": {
                        "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-001/subnets/subnet-001"
                      },
                      "privateIPAddressVersion": "IPv4",
                      "loadBalancerBackendAddressPools": [
                        {
                          "id": "/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/loadBalancers/kubernetes/backendAddressPools/kubernetes"
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
  }
```

### Configure with Bicep

To deploy an virtual machine scale set that pass this rule:

- Set `properties.virtualMachineProfile.OsProfile.linuxConfiguration.disablePasswordAuthentication` to `true`.

For example:

```bicep
resource vmScaleSet 'Microsoft.Compute/virtualMachineScaleSets@2021-11-01' = {
  name: 'vmss-01'
  location: resourceGroup().location
  sku: {
    name: 'b2ms'
    tier: 'Standard'
    capacity: 1
  }
  properties: {
    overprovision: true
    upgradePolicy: {
      mode: 'Automatic'
    }
    singlePlacementGroup: true
    platformFaultDomainCount: 3
    virtualMachineProfile: {
      storageProfile: {
        osDisk: {
          caching: 'ReadWrite'
          createOption: 'FromImage'
        }
        imageReference: {
          publisher: 'microsoft-aks'
          offer: 'aks'
          sku: 'aks-ubuntu-1804-202208'
          version: '2022.08.29'
        }    
      }
      osProfile: {
        adminUsername: 'azureuser'
        computerNamePrefix: 'vmss-01'
        linuxConfiguration: {
          disablePasswordAuthentication: true
          }
          provisionVMAgent: true
          ssh: {
            publicKeys: [
              {
                path: '/home/azureuser/.ssh/authorized_keys'
              }
            ]
          }
        }
      networkProfile: {
        networkInterfaceConfigurations: [
          {
            name: 'vmss-001'
            properties: {
              primary: true
              enableAcceleratedNetworking: true
              networkSecurityGroup: {
                id: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/networkSecurityGroups/nsg-001'
              }
              ipConfigurations: [
                {
                  name: 'ipconfig1'
                  properties: {
                    primary: true
                    subnet: {
                      id: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/virtualNetworks/vnet-001/subnets/subnet-001'
                    }
                    privateIPAddressVersion: 'IPv4'
                    loadBalancerBackendAddressPools: [
                      {
                        id:  '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/loadBalancers/kubernetes/backendAddressPools/kubernetes'
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
}
```

## LINKS

- [Identity and access management](https://learn.microsoft.com/azure/architecture/framework/security/design-identity)
- [Azure security baseline for Linux Virtual Machines](https://learn.microsoft.com/security/benchmark/azure/baselines/virtual-machines-linux-security-baseline)
- [Detailed steps: Create and manage SSH keys for authentication to a Linux VM in Azure](https://learn.microsoft.com/azure/virtual-machines/linux/create-ssh-keys-detailed)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachinescalesets)
