// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// An example simple Linux VMSS

@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

@description('A unique identifier for the VNET subnet.')
param subnetId string

@description('A unique identifier for the load balancer backend pool.')
param backendPoolId string

@description('The admin username used for each VM instance.')
param adminUsername string

// An example of a simple Linux VMSS with a system-assigned managed identity.
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
