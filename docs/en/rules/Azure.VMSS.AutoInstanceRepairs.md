---
reviewed: 2025-05-30
severity: Important
pillar: Reliability
category: RE:07 Self-preservation
resource: Virtual Machine Scale Sets
resourceType: Microsoft.Compute/virtualMachineScaleSets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VMSS.AutoInstanceRepairs/
---

# Virtual Machine Scale Set automatic repair policy is not enabled

## SYNOPSIS

Applications or infrastructure relying on a virtual machine scale sets may fail if VM instances are unhealthy.

## DESCRIPTION

Virtual Machine Scale Sets (VMSS) provide management and scaling automation for a set of virtual machine (VM) instances.
One feature of VMSS is the ability to detect and automatically repair unhealthy VM instances.
When enabled, _automatic instance repairs_ helps achieve reliability by maintaining a set of healthy instances.
Automatic instance repairs does this by:

1. Monitoring the health of VM instances.
2. Performing pre-configured repair action when an unhealthy instance is detected.

To enable automatic instance repairs, you must:

- Configure application health monitoring with either the Application Health extension or Load balancer health probes.
- Configure the `automaticRepairsPolicy` property in the VMSS resource definition.
  This policy configuration allows automatic repairs to be enabled, a grace time, and the repair action to be configured.

See documentation references below for additional details.

## RECOMMENDATION

Consider enabling automatic instance repair of unhealthy VM instances in a virtual machine scale set.

## EXAMPLES

### Configure with Bicep

To deploy virtual machine scale sets that pass this rule:

- Set the `properties.automaticRepairsPolicy.enabled` property to `true`.
- Optionally:
  - Set the `properties.automaticRepairsPolicy.gracePeriod` property to specify a grace period before repairs are initiated.
    By default, the grace period is 10 minutes.
    The grace period should be set to an interval that allows the instance to stabilize after initial deployment.
  - Set the `properties.automaticRepairsPolicy.repairAction` property to specify the repair action.
    The default repair action is `Replace`, which deletes and recreates the unhealthy instance with a new one.
    Other repair actions include `Reimage` and `Restart`.

For example:

```bicep
resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2024-11-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Standard_D8ds_v6'
    tier: 'Standard'
    capacity: 3
  }
  properties: {
    overprovision: true
    upgradePolicy: {
      mode: 'Automatic'
    }
    automaticRepairsPolicy: {
      enabled: true
      gracePeriod: 'PT10M'
      repairAction: 'Replace'
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
          offer: 'azure-linux-3'
          sku: 'azure-linux-3-gen2-fips'
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

<!-- external:avm avm/res/compute/virtual-machine-scale-set automaticRepairsPolicyEnabled -->

### Configure with Azure template

To deploy virtual machine scale sets that pass this rule:

- Set the `properties.automaticRepairsPolicy.enabled` property to `true`.
- Optionally:
  - Set the `properties.automaticRepairsPolicy.gracePeriod` property to specify a grace period before repairs are initiated.
    By default, the grace period is 10 minutes.
    The grace period should be set to an interval that allows the instance to stabilize after initial deployment.
  - Set the `properties.automaticRepairsPolicy.repairAction` property to specify the repair action.
    The default repair action is `Replace`, which deletes and recreates the unhealthy instance with a new one.
    Other repair actions include `Reimage` and `Restart`.

For example:

```json
{
  "type": "Microsoft.Compute/virtualMachineScaleSets",
  "apiVersion": "2024-11-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  },
  "sku": {
    "name": "Standard_D8ds_v6",
    "tier": "Standard",
    "capacity": 3
  },
  "properties": {
    "overprovision": true,
    "upgradePolicy": {
      "mode": "Automatic"
    },
    "automaticRepairsPolicy": {
      "enabled": true,
      "gracePeriod": "PT10M",
      "repairAction": "Replace"
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
          "offer": "azure-linux-3",
          "sku": "azure-linux-3-gen2-fips",
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

## LINKS

- [RE:07 Self-preservation](https://learn.microsoft.com/azure/well-architected/reliability/self-preservation)
- [Automatic instance repairs](https://learn.microsoft.com/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-automatic-instance-repairs)
- [Using Application Health extension with Virtual Machine Scale Sets](https://learn.microsoft.com/azure/virtual-machine-scale-sets/virtual-machine-scale-sets-health-extension)
- [Azure Load Balancer health probes](https://learn.microsoft.com/azure/load-balancer/load-balancer-custom-probe-overview)
- [Configure a Virtual Machine Scale Set with an existing Azure Standard Load Balancer](https://learn.microsoft.com/azure/load-balancer/configure-vm-scale-set-portal)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachinescalesets#automaticrepairspolicy)
