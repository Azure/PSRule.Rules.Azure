---
reviewed: 2026-04-04
severity: Important
pillar: Security
category: SE:08 Hardening resources
resource: Virtual Machine
resourceType: Microsoft.Compute/virtualMachines
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.SecureBoot/
---

# Virtual Machine Secure Boot is not enabled

## SYNOPSIS

Operating systems or drivers may be maliciously modified or injected if an actor gains access to VM/ OS storage or build media.

## DESCRIPTION

Azure Virtual Machines (VMs) are able to run a wide range of operating systems including many distributions of Windows and Linux.
A malicious actor may attempt to tamper or inject operating system and driver components to gain access to resources and persist between reboots.

When a VM is started, Azure is able to verify if:

1. The operating system and drivers are originate from a trusted source.
2. These components are in their original unaltered state.

Azure is able to perform this verification by Secure Boot and Trusted Launch features.
These features verify the cryptographic signatures of early boot components before they start.

Secure Boot and Trusted Launch are on by default for many configurations.
However, if you are running an older configuration these features may need to be enabled.

## RECOMMENDATION

Consider enabling Trusted Launch or Confidential VM with Secure Boot for virtual machines to protect against boot-level attacks.

## EXAMPLES

### Configure with Bicep

To deploy virtual machines that pass this rule:

- Set the `properties.securityProfile.securityType` property to `TrustedLaunch` or `ConfidentialVM`.
- Set the `properties.securityProfile.uefiSettings.secureBootEnabled` property to `true`.

For example:

```bicep
resource vm 'Microsoft.Compute/virtualMachines@2024-03-01' = {
  name: name
  location: location
  properties: {
    securityProfile: {
      securityType: 'TrustedLaunch'
      uefiSettings: {
        secureBootEnabled: true
        vTpmEnabled: true
      }
    }
  }
}
```

<!-- external:avm avm/res/compute/virtual-machine secureBootEnabled,securityType -->

### Configure with Azure template

To deploy virtual machines that pass this rule:

- Set the `properties.securityProfile.securityType` property to `TrustedLaunch` or `ConfidentialVM`.
- Set the `properties.securityProfile.uefiSettings.secureBootEnabled` property to `true`.

For example:

```json
{
  "type": "Microsoft.Compute/virtualMachines",
  "apiVersion": "2024-03-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "securityProfile": {
      "securityType": "TrustedLaunch",
      "uefiSettings": {
        "secureBootEnabled": true,
        "vTpmEnabled": true
      }
    }
  }
}
```

## NOTES

Currently there are a few limitations (see documentation for up to date details), including:

- A supported VM SKU and operating system is required.
- Upgrading existing VMs:
  - SecureBoot and Trusted Launch is only supported on Generation 2 VM images, however generation 1 VMs can be upgraded.
  - Some backup and operating system configuration prerequisites are required before to enable Trusted Launch.
- The following VM features aren't supported with Trusted Launch:
  - Managed Image (use an image from an Azure Compute Gallery instead).
  - Linux VM Hibernation.

## LINKS

- [SE:08 Hardening resources](https://learn.microsoft.com/azure/well-architected/security/harden-resources)
- [Security: Level 2](https://learn.microsoft.com/azure/well-architected/security/maturity-model?tabs=level2)
- [Trusted Launch for Azure virtual machines](https://learn.microsoft.com/azure/virtual-machines/trusted-launch)
- [Enable Trusted launch on existing Azure Gen2 VMs](https://learn.microsoft.com/azure/virtual-machines/trusted-launch-existing-vm)
- [Upgrade existing Azure Gen1 VMs to Trusted launch](https://learn.microsoft.com/azure/virtual-machines/trusted-launch-existing-vm-gen-1)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines#securityprofile)
