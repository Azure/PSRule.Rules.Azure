---
severity: Important
pillar: Security
category: SE:08 Hardening resources
resource: Virtual Machine
resourceType: Microsoft.Compute/virtualMachines
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.SecureBoot/
---

# VM should use Secure Boot

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

## LINKS

- [SE:08 Hardening resources](https://learn.microsoft.com/azure/well-architected/security/harden-resources)
- [Trusted Launch for Azure virtual machines](https://learn.microsoft.com/azure/virtual-machines/trusted-launch)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines#securityprofile)
