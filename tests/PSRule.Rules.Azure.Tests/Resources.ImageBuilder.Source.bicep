// Copyright (c) Microsoft Corporation.
// Licensed under the MIT License.

// An example if a failing image template with source hashes.
module image_001 'br/public:avm/res/virtual-machine-images/image-template:0.5.0' = {
  params: {
    name: 'image-001'
    baseTime: '0'
    distributions: [
      {
        type: 'ManagedImage'
        imageName: 'image-001'
      }
    ]
    imageSource: {
      type: 'PlatformImage'
      publisher: 'canonical'
      offer: 'ubuntu-24_04-lts'
      sku: 'server'
      version: 'latest'
    }
    managedIdentities: {}
    customizationSteps: [
      {
        type: 'Shell'
        name: 'PowerShell installation'
        scriptUri: 'https://raw.githubusercontent.com/Azure/bicep-registry-modules/refs/heads/main/avm/res/virtual-machine-images/image-template/tests/e2e/max/src/Install-LinuxPowerShell.sh'
      }
    ]
    validationProcess: {
      inVMValidations: [
        {
          type: 'Shell'
          name: 'Validate PowerShell'
          scriptUri: 'https://raw.githubusercontent.com/Azure/bicep-registry-modules/refs/heads/main/avm/res/virtual-machine-images/image-template/tests/e2e/max/src/Install-LinuxPowerShell.sh'
        }
      ]
    }
    buildTimeoutInMinutes: 60
    vmSize: 'Standard_D2s_v3'
  }
}

// An example if a passing image template with source hashes.
module image_002 'br/public:avm/res/virtual-machine-images/image-template:0.5.0' = {
  params: {
    name: 'image-002'
    baseTime: '0'
    distributions: [
      {
        type: 'ManagedImage'
        imageName: 'image-002'
      }
    ]
    imageSource: {
      type: 'PlatformImage'
      publisher: 'canonical'
      offer: 'ubuntu-24_04-lts'
      sku: 'server'
      version: 'latest'
    }
    managedIdentities: {}
    customizationSteps: [
      {
        type: 'Shell'
        name: 'PowerShell installation'
        scriptUri: 'https://raw.githubusercontent.com/Azure/bicep-registry-modules/refs/heads/main/avm/res/virtual-machine-images/image-template/tests/e2e/max/src/Install-LinuxPowerShell.sh'
        sha256Checksum: '8d469f6864a38e1cf957cd080603026bba325793edfb4fe2e8b8e7368eb15b92'
      }
    ]
    validationProcess: {
      inVMValidations: [
        {
          type: 'Shell'
          name: 'Validate PowerShell'
          scriptUri: 'https://raw.githubusercontent.com/Azure/bicep-registry-modules/refs/heads/main/avm/res/virtual-machine-images/image-template/tests/e2e/max/src/Install-LinuxPowerShell.sh'
          sha256Checksum: '8d469f6864a38e1cf957cd080603026bba325793edfb4fe2e8b8e7368eb15b92'
        }
      ]
    }
    buildTimeoutInMinutes: 60
    vmSize: 'Standard_D2s_v3'
  }
}

// A basic example that doesn't use any external scripts.
module image_003 'br/public:avm/res/virtual-machine-images/image-template:0.5.0' = {
  params: {
    name: 'image-003'
    baseTime: '0'
    distributions: [
      {
        type: 'ManagedImage'
        imageName: 'image-003'
      }
    ]
    imageSource: {
      type: 'PlatformImage'
      publisher: 'canonical'
      offer: 'ubuntu-24_04-lts'
      sku: 'server'
      version: 'latest'
    }
    managedIdentities: {}
    buildTimeoutInMinutes: 60
    vmSize: 'Standard_D2s_v3'
  }
}
