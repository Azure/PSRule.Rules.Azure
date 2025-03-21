---
reviewed: 2025-03-06
severity: Important
pillar: Security
category: SE:02 Secured development lifecycle
resource: VM Image Builder
resourceType: Microsoft.VirtualMachineImages/imageTemplates
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ImageBuilder.CustomizeHash/
---

# Image Builder customization script is not pinned

## SYNOPSIS

External scripts that are not pinned may be modified to execute privileged actions by an unauthorized user.

## DESCRIPTION

When building and developing VM images it is common to execute scripts to customize and validate the image.
Scripts that are used to customize the image can be stored in a variety of locations including a public or private URLs.

During the process of building and validating the image scripts often have privileged access to the image.
Additionally, many of the normal operating system (OS) security features are disabled during the build process.
This can make the image vulnerable to supply chain attacks that could be latter rolled out to development and production.

Azure Image Builder allows you to configure a SHA-256 hash for external scripts.
This hash can be used to verify the integrity of the script before it is executed.

## RECOMMENDATION

Consider reviewing all scripts and using a hash to ensure customization scripts have not been modified since they were last reviewed.

## EXAMPLES

### Configure with Bicep

To deploy image templates that pass this rule:

- Set the `properties.customize[*].sha256Checksum` property to a SHA-256 hash if `sourceUri` or `scriptUri` is used.
  - The `sha256Checksum` should be a SHA-256 hash of the script content.
  - This applies when the `type` is `Shell`, `PowerShell`, or `File`.

For example:

```bicep
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
```

### Configure with Azure template

To deploy image templates that pass this rule:

- Set the `properties.customize[*].sha256Checksum` property to a SHA-256 hash if `sourceUri` or `scriptUri` is used.
  - The `sha256Checksum` should be a SHA-256 hash of the script content.
  - This applies when the `type` is `Shell`, `PowerShell`, or `File`.

For example:

```json
{
  "type": "Microsoft.VirtualMachineImages/imageTemplates",
  "apiVersion": "2024-02-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "UserAssigned",
    "userAssignedIdentities": {
      "[format('{0}', parameters('identityId'))]": {}
    }
  },
  "properties": {
    "source": {
      "type": "PlatformImage",
      "publisher": "canonical",
      "offer": "ubuntu-24_04-lts",
      "sku": "server",
      "version": "latest"
    },
    "distribute": [
      {
        "location": "[parameters('location')]",
        "imageId": "[parameters('imageId')]",
        "runOutputName": "[parameters('outputRunName')]",
        "type": "ManagedImage",
        "artifactTags": {
          "sourceType": "PlatformImage",
          "sourcePublisher": "canonical",
          "sourceOffer": "ubuntu-24_04-lts",
          "sourceSku": "server",
          "sourceVersion": "latest"
        }
      }
    ],
    "customize": [
      {
        "type": "Shell",
        "name": "PowerShell installation",
        "scriptUri": "https://raw.githubusercontent.com/Azure/bicep-registry-modules/5bbac220dfdf8643fb0091e23095ce875f7fe54b/avm/res/virtual-machine-images/image-template/tests/e2e/max/src/Install-LinuxPowerShell.sh",
        "sha256Checksum": "8d469f6864a38e1cf957cd080603026bba325793edfb4fe2e8b8e7368eb15b92"
      }
    ],
    "validate": {
      "inVMValidations": [
        {
          "type": "PowerShell",
          "name": "Run PowerShell script",
          "scriptUri": "https://raw.githubusercontent.com/Azure/azure-quickstart-templates/5670db39d51799c896f1f8223f32b8ba08cc816e/demos/imagebuilder-windowsbaseline/scripts/runScript.ps1",
          "sha256Checksum": "c76d82a68e57b559ea82bcb191b48f5e08a391b036ba5fa0b9c3efe795131e82"
        }
      ]
    }
  }
}
```

## LINKS

- [SE:02 Secured development lifecycle](https://learn.microsoft.com/azure/well-architected/security/secure-development-lifecycle)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/Microsoft.VirtualMachineImages/imageTemplates)
