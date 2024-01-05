---
severity: Important
pillar: Operational Excellence
category: OE:07 Monitoring system
resource: Virtual Machine Scale Sets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VMSS.AMA/
---

# Use Azure Monitor Agent

## SYNOPSIS

Use Azure Monitor Agent for collecting monitoring data from VM scale sets.

## DESCRIPTION

Azure Monitor Agent (AMA) collects monitoring data from the guest operating system of virtual machine scale sets (VMSS) instances.
Data collected gets delivered to Azure Monitor for use by features, insights and other services, such as Microsoft Defender for Cloud.

Azure Monitor Agent replaces all of Azure Monitor's legacy monitoring agents.

## RECOMMENDATION

Consider monitoring Virtual Machine Scale Sets instances using the Azure Monitor Agent.

## EXAMPLES

### Configure with Azure template

To deploy virtual machine scale sets that pass this rule:

- Set `properties.virtualMachineProfile.extensionProfile.extensions.properties.publisher` to `Microsoft.Azure.Monitor`.
- Set `properties.virtualMachineProfile.extensionProfile.extensions.properties.type` to `AzureMonitorWindowsAgent` (Windows) or `AzureMonitorLinuxAgent` (Linux).

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vmssName": {
      "type": "string",
      "defaultValue": "vmss-01"
    },
    "location": {
      "type": "string"
    }
  },
  "resources": [
    {
      "type": "Microsoft.Compute/virtualMachineScaleSets",
      "apiVersion": "2022-08-01",
      "name": "[parameters('vmssName')]",
      "location": "[parameters('location')]",
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
          "extensionProfile": {
            "extensions": [
              {
                "name": "[format('{0}/AzureMonitorLinuxAgent', parameters('vmssName'))]",
                "properties": {
                  "autoUpgradeMinorVersion": true,
                  "enableAutomaticUpgrade": true,
                  "publisher": "Microsoft.Azure.Monitor",
                  "type": "AzureMonitorLinuxAgent",
                  "typeHandlerVersion": "1.21"
                }
              }
            ]
          },
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
  ]
}
```

To deploy virtual machine scale sets with a extension sub resource that pass this rule:

- Deploy a extension sub-resource `Microsoft.Compute/virtualMachines/extensions`.
- Set `properties.publisher` to `Microsoft.Azure.Monitor`.
- Set `properties.type` to `AzureMonitorWindowsAgent` (Windows) or `AzureMonitorLinuxAgent` (Linux).

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vmssName": {
      "type": "string"
    },
    "location": {
      "type": "string"
    },
    "userAssignedManagedIdentity": {
      "type": "string"
    }
  },
  "resources": [
    {
      "type": "Microsoft.Compute/virtualMachineScaleSets/extensions",
      "apiVersion": "2022-08-01",
      "name": "[format('{0}/AzureMonitorLinuxAgent', parameters('vmssName'))]",
      "location": "[parameters('location')]",
      "properties": {
        "publisher": "Microsoft.Azure.Monitor",
        "type": "AzureMonitorLinuxAgent",
        "typeHandlerVersion": "1.21",
          "settings": {
          "authentication": {
            "managedIdentity": {
              "identifier-name": "mi_res_id",
              "identifier-value": "[parameters('userAssignedManagedIdentity')]"
            }
          }
        },
        "autoUpgradeMinorVersion": true,
        "enableAutomaticUpgrade": true
      }
    }
  ]
}
```

### Configure with Bicep

To deploy virtual machine scale sets that pass this rule:

- Set `properties.virtualMachineProfile.extensionProfile.extensions.properties.publisher` to `Microsoft.Azure.Monitor`.
- Set `properties.virtualMachineProfile.extensionProfile.extensions.properties.type` to `AzureMonitorWindowsAgent` (Windows) or `AzureMonitorLinuxAgent` (Linux).

For example:

```bicep
param vmssName string = 'vmss-01'
param location string

resource vmScaleSet 'Microsoft.Compute/virtualMachineScaleSets@2022-08-01' = {
  name: vmssName
  location: location
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
      extensionProfile: {
        extensions: [
          {
            name: '${vmssName}/AzureMonitorLinuxAgent'

            properties: {
              autoUpgradeMinorVersion: true
              enableAutomaticUpgrade: true
              publisher: 'Microsoft.Azure.Monitor'
              type: 'AzureMonitorLinuxAgent'
              typeHandlerVersion: '1.21'
            }
          }
        ]
      }
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
                        id: '/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/test-rg/providers/Microsoft.Network/loadBalancers/kubernetes/backendAddressPools/kubernetes'
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

To deploy virtual machine scale sets with a extension sub resource that pass this rule:

- Deploy a extension sub-resource `Microsoft.Compute/virtualMachines/extensions`.
- Set `properties.publisher` to `Microsoft.Azure.Monitor`.
- Set `properties.type` to `AzureMonitorWindowsAgent` (Windows) or `AzureMonitorLinuxAgent` (Linux).

For example:

```bicep
param vmssName string
param location string
param userAssignedManagedIdentity string

resource linuxAgent 'Microsoft.Compute/virtualMachineScaleSets/extensions@2022-08-01' = {
  name: '${vmssName}/AzureMonitorLinuxAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorLinuxAgent'
    typeHandlerVersion: '1.21'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      authentication: {
        managedIdentity: {
          identifier-name: 'mi_res_id'
          identifier-value: userAssignedManagedIdentity
        }
      }
    }
  }
}
```

## NOTES

The Azure Monitor Agent (AMA) itself does not include all configuration needed,
additionally data collection rules and associations are required.

## LINKS

- [OE:07 Monitoring system](https://learn.microsoft.com/azure/well-architected/operational-excellence/observability)
- [Azure Monitor Agent overview](https://learn.microsoft.com/azure/azure-monitor/agents/agents-overview)
- [Manage Azure Monitor Agent](https://learn.microsoft.com/azure/azure-monitor/agents/azure-monitor-agent-manage)
- [Azure virtual machine scale set deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachinescalesets)
- [Azure extension deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachinescalesets/extensions)
