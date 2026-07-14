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

Azure Fleet virtual machine profiles are able to run a wide range of operating systems including many distributions of Windows and Linux.
A malicious actor may attempt to tamper or inject operating system and driver components to gain access to resources and persist between reboots.

When a fleet VM instance is started, Azure is able to verify if:

1. The operating system and drivers originate from a trusted source.
2. These components are in their original unaltered state.

Azure is able to perform this verification by Secure Boot and Trusted Launch features.
These features verify the cryptographic signatures of early boot components before they start.

Secure Boot and Trusted Launch are on by default for many configurations.
However, if you are running an older configuration these features may need to be enabled.

Setting the security type to `ConfidentialVM` is also acceptable.

## RECOMMENDATION

Consider enabling Trusted Launch or Confidential VM with Secure Boot for Azure Fleet VM profiles to protect against boot-level attacks.

## EXAMPLES

### Configure with Bicep

To deploy an Azure Fleet that passes this rule:

- Set the `properties.computeProfile.baseVirtualMachineProfile.securityProfile.securityType` property to `TrustedLaunch` or `ConfidentialVM`.
- Set the `properties.computeProfile.baseVirtualMachineProfile.securityProfile.uefiSettings.secureBootEnabled` property to `true`.

For example:

```bicep
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
}
```

### Configure with Azure template

To deploy an Azure Fleet that passes this rule:

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
          "encryptionAtHost": true,
          "uefiSettings": {
            "secureBootEnabled": true,
            "vTpmEnabled": true
          }
        },
        "osProfile": {
          "computerNamePrefix": "fleet",
          "adminUsername": "[parameters('adminUsername')]",
          "adminPassword": "[parameters('secret')]"
        },
        "networkProfile": {
          "networkInterfaceConfigurations": [
            {
              "name": "netconfig",
              "properties": {
                "ipConfigurations": [
                  {
                    "name": "ipconfig",
                    "properties": {
                      "primary": true,
                      "subnet": {
                        "id": "[parameters('subnetId')]"
                      }
                    }
                  }
                ]
              }
            }
          ]
        }
      }
    },
    "vmSizesProfile": [
      {
        "name": "Standard_D8ds_v6",
        "rank": 0
      }
    ],
    "regularPriorityProfile": {
      "minCapacity": 1,
      "capacity": 5,
      "allocationStrategy": "Prioritized"
    }
  }
}
```

## NOTES

Currently there are a few limitations (see documentation for up to date details), including:

- A supported VM SKU and operating system is required.
- Secure Boot and Trusted Launch is only supported on Generation 2 VM images.

## LINKS

- [SE:08 Hardening resources](https://learn.microsoft.com/azure/well-architected/security/harden-resources)
- [Security: Level 2](https://learn.microsoft.com/azure/well-architected/security/maturity-model?tabs=level2)
- [Trusted Launch for Azure virtual machines](https://learn.microsoft.com/azure/virtual-machines/trusted-launch)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.azurefleet/fleets#securityprofile)
