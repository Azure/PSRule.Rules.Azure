---
reviewed: 2026-07-14
severity: Important
pillar: Security
category: SE:08 Hardening resources
resource: Azure Fleet
resourceType: Microsoft.AzureFleet/fleets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Fleet.SecureBoot/
---

# Azure Fleet Secure Boot is not enabled

## SYNOPSIS

Operating systems or drivers may be maliciously modified or injected if an actor gains access to VM/ OS storage or build media.

## DESCRIPTION

Azure Fleets deploy and manage virtual machines at scale using a base virtual machine profile.
A malicious actor may attempt to tamper or inject operating system and driver components to gain access to resources and persist between reboots.

When a fleet VM is started, Azure is able to verify if:

1. The operating system and drivers originate from a trusted source.
2. These components are in their original unaltered state.

Azure is able to perform this verification by Secure Boot and Trusted Launch features.
These features verify the cryptographic signatures of early boot components before they start.

Secure Boot and Trusted Launch are on by default for many configurations.
However, if you are running an older configuration these features may need to be enabled.

## RECOMMENDATION

Consider enabling Trusted Launch or Confidential VM with Secure Boot for Azure Fleet base virtual machine profiles to protect against boot-level attacks.

## EXAMPLES

### Configure with Bicep

To deploy Azure Fleets that pass this rule:

- Set the `properties.computeProfile.baseVirtualMachineProfile.securityProfile.securityType` property to `TrustedLaunch` or `ConfidentialVM`.
- Set the `properties.computeProfile.baseVirtualMachineProfile.securityProfile.uefiSettings.secureBootEnabled` property to `true`.

For example:

```bicep
resource fleet 'Microsoft.AzureFleet/fleets@2024-11-01' = {
  name: name
  location: location
  properties: {
    computeProfile: {
      baseVirtualMachineProfile: {
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
}
```

### Configure with Azure template

To deploy Azure Fleets that pass this rule:

- Set the `properties.computeProfile.baseVirtualMachineProfile.securityProfile.securityType` property to `TrustedLaunch` or `ConfidentialVM`.
- Set the `properties.computeProfile.baseVirtualMachineProfile.securityProfile.uefiSettings.secureBootEnabled` property to `true`.

For example:

```json
{
  "type": "Microsoft.AzureFleet/fleets",
  "apiVersion": "2024-11-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "computeProfile": {
      "baseVirtualMachineProfile": {
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
}
```

## LINKS

- [SE:08 Hardening resources](https://learn.microsoft.com/security/benchmark/azure/security-baselines-platform#se-08-hardening-resources)
- [Trusted launch for Azure virtual machines](https://learn.microsoft.com/azure/virtual-machines/trusted-launch)
- [Security profile](https://learn.microsoft.com/azure/templates/microsoft.azurefleet/fleets#securityprofile)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.azurefleet/fleets)
