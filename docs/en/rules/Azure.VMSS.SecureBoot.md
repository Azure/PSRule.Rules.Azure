---
severity: Important
pillar: Security
category: SE:08 Hardening resources
resource: Virtual Machine Scale Set
resourceType: Microsoft.Compute/virtualMachineScaleSets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VMSS.SecureBoot/
---

# VMSS should use Secure Boot

## SYNOPSIS

Virtual machine scale sets should use Trusted Launch with Secure Boot enabled.

## DESCRIPTION

Trusted Launch protects against advanced and persistent attack techniques by combining technologies that can be independently enabled like Secure Boot and virtualized version of trusted platform module (vTPM).

Secure Boot, which is implemented in platform firmware, protects against the installation of malware-based rootkits and boot kits.
Secure Boot ensures that only signed operating systems and drivers can boot.
It establishes a "root of trust" for the software stack on your VM.

Setting the security type to `ConfidentialVM` is also acceptable.

## RECOMMENDATION

Consider enabling Trusted Launch with Secure Boot for virtual machine scale sets to protect against boot-level attacks.

## EXAMPLES

### Configure with Azure template

To deploy virtual machine scale sets that pass this rule:

- Set the `properties.virtualMachineProfile.securityProfile.securityType` property to `TrustedLaunch` or `ConfidentialVM`.
- Set the `properties.virtualMachineProfile.securityProfile.uefiSettings.secureBootEnabled` property to `true`.

For example:

```json
{
  "type": "Microsoft.Compute/virtualMachineScaleSets",
  "apiVersion": "2024-03-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "virtualMachineProfile": {
      "securityProfile": {
        "securityType": "TrustedLaunch",
        "uefiSettings": {
          "secureBootEnabled": true,
          "vTpmEnabled": true
        }
      }
    }
  }
}
```

### Configure with Bicep

To deploy virtual machine scale sets that pass this rule:

- Set the `properties.virtualMachineProfile.securityProfile.securityType` property to `TrustedLaunch` or `ConfidentialVM`.
- Set the `properties.virtualMachineProfile.securityProfile.uefiSettings.secureBootEnabled` property to `true`.

For example:

```bicep
resource vmss 'Microsoft.Compute/virtualMachineScaleSets@2024-03-01' = {
  name: name
  location: location
  properties: {
    virtualMachineProfile: {
      securityProfile: {
        securityType: 'TrustedLaunch'
        uefiSettings: {
          secureBootEnabled: true
          vTpmEnabled: true
        }
      }
    }
  }
}
```

## LINKS

- [SE:08 Hardening resources](https://learn.microsoft.com/azure/well-architected/security/harden-resources)
- [Trusted Launch for Azure virtual machines](https://learn.microsoft.com/azure/virtual-machines/trusted-launch)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachinescalesets#securityprofile)
