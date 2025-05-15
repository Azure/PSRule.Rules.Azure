// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

@description('The name of the local administrator account.')
param adminUsername string

@secure()
@description('The password for the local administrator account.')
param secret string

@description('The ID of the subnet where the fleet will be deployed.')
param subnetId string

// An example of creating a fleet resource with a Trusted Launch security profile.
resource windows_fleet 'Microsoft.AzureFleet/fleets@2024-11-01' = {
  name: name
  location: location
  properties: {
    computeProfile: {
      baseVirtualMachineProfile: {
        securityProfile: {
          securityType: 'TrustedLaunch'
          encryptionAtHost: true
          uefiSettings: {
            secureBootEnabled: true
            vTpmEnabled: true
          }
        }
        osProfile: {
          computerNamePrefix: 'fleet'
          adminUsername: adminUsername
          adminPassword: secret
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
  zones: [
    '1'
    '2'
    '3'
  ]
}
