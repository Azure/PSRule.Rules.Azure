// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// Bicep documentation examples

@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

@description('The image ID to distribute the image to.')
param imageId string

@description('The name of the output run to distribute the image to.')
param outputRunName string

@description('The managed identity used to create Azure resources.')
param identityId string

// An example of a resource that creates an image builder using external scripts and hashes.
resource imageBuilder 'Microsoft.VirtualMachineImages/imageTemplates@2024-02-01' = {
  name: name
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${identityId}': {}
    }
  }
  properties: {
    source: {
      type: 'PlatformImage'
      publisher: 'canonical'
      offer: 'ubuntu-24_04-lts'
      sku: 'server'
      version: 'latest'
    }
    distribute: [
      {
        location: location
        imageId: imageId
        runOutputName: outputRunName
        type: 'ManagedImage'
        artifactTags: {
          sourceType: 'PlatformImage'
          sourcePublisher: 'canonical'
          sourceOffer: 'ubuntu-24_04-lts'
          sourceSku: 'server'
          sourceVersion: 'latest'
        }
      }
    ]
    customize: [
      {
        type: 'Shell'
        name: 'PowerShell installation'
        scriptUri: 'https://raw.githubusercontent.com/Azure/bicep-registry-modules/5bbac220dfdf8643fb0091e23095ce875f7fe54b/avm/res/virtual-machine-images/image-template/tests/e2e/max/src/Install-LinuxPowerShell.sh'
        sha256Checksum: '8d469f6864a38e1cf957cd080603026bba325793edfb4fe2e8b8e7368eb15b92'
      }
    ]
    validate: {
      inVMValidations: [
        {
          type: 'PowerShell'
          name: 'Run PowerShell script'
          scriptUri: 'https://raw.githubusercontent.com/Azure/azure-quickstart-templates/5670db39d51799c896f1f8223f32b8ba08cc816e/demos/imagebuilder-windowsbaseline/scripts/runScript.ps1'
          sha256Checksum: 'c76d82a68e57b559ea82bcb191b48f5e08a391b036ba5fa0b9c3efe795131e82'
        }
      ]
    }
  }
}
