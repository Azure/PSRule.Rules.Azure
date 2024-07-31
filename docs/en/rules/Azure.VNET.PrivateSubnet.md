---
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Virtual Network
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNET.PrivateSubnet/
---

# Disable default outbound access

## SYNOPSIS

Disable default outbound access for virtual machines.

## DESCRIPTION

By default, virtual machines (VMs) created in a virtual network without explicit outbound connectivity are assigned a default outbound public IP address. This IP address enables outbound connectivity to the internet.

Why disable default outbound access?

- Security: Following the zero trust network security principle, it is not recommended to expose a virtual network to the internet by default.
- Explicit Connectivity: It is better to use explicit methods of connectivity rather than implicit ones for granting internet access to VMs.
- Ownership and Stability: The default outbound access IP is managed by Microsoft, and its ownership or address might change, potentially causing disruptions.

Enabling the private subnet feature on a subnet prevents VMs within that subnet from using default outbound access to connect to public endpoints.

This also applies to VMs within a scale set configured with uniform orchestration mode.

Recommended approach:

- Use explicit methods for public connectivity, such as:
  - NAT Gateway: Provides a stable and owned public IP for outbound connectivity.
  - Firewall: Offers outbound connectivity with built-in NAT capabilities.

Note that there are limitations to this feature, so please refer to the documentation for detailed information.

## RECOMMENDATION

Consider using an explicit method of public connectivity for virtual machines.

## EXAMPLES

### Configure with Azure template

For each subnet object in defined the `properties.subnets` property:
  - Set the `properties.defaultOutboundAccess` property to `false`.

For example:

```json
{
  "type": "Microsoft.Network/virtualNetworks",
  "apiVersion": "2023-11-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "addressSpace": {
      "addressPrefixes": [
        "10.0.0.0/16"
      ]
    },
    "subnets": [
      {
        "name": "subnet-A",
        "properties": {
          "addressPrefix": "10.0.0.0/27",
           "defaultOutboundAccess": false
        }
      },
      {
        "name": "subnet-B",
        "properties": {
          "addressPrefix": "10.0.0.32/27",
          "defaultOutboundAccess": false
        }
      }
    ]
  }
}
```

### Configure with Bicep

To configure virtual networks that pass this rule:

For each subnet object in defined the `properties.subnets` property:
  - Set the `properties.defaultOutboundAccess` property to `false`.

For example:

```bicep
resource vnet 'Microsoft.Network/virtualNetworks@2023-11-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet-A'
        properties: {
          addressPrefix: '10.0.0.0/27'
          defaultOutboundAccess: false
        }
      }
      {
        name: 'subnet-B'
        properties: {
          addressPrefix: '10.0.0.32/27'
          defaultOutboundAccess: false
        }
      }
    ]
  }
}
```

## NOTES

This feature is currently in preview.

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Default outbound access](https://learn.microsoft.com/azure/virtual-network/ip-services/default-outbound-access)
- [Azure deployment reference - Virtual Network](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks)
- [Azure deployment reference - Subnet](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks/subnets)
