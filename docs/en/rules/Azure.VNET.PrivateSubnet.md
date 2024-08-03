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

Azure virtual network (VNET) subnets support disabling default outbound Internet access.
By default, virtual machines (VMs) have outbound connectivity to the Internet.
Default outbound Internet access also applies to virtual machine scale sets (VMSS) configured with the uniform orchestration mode.

When default outbound is enabled traffic to the Internet is automatically routing via a shared NAT pool.
The IP address used by the shared NAT pool is used across multiple customers, and is subject to change.

Default outbound access for new VMs and VMSS is scheduled for retirement in September 2025.

Alternatively, outbound access to the Internet can be explictly configured.
Explicit outbound access has the following benefits:

- **Security**: Outbound Internet access can be used to transfer data or control out of your organization.
  Controlling outbound access allows you to make an explict choice about which workloads require this vs those that don't.
- **Ownership and stability**: The default outbound access IP is managed by Microsoft and used by multiple customers.
  As a result, you can't assume use the address for network security rules and the address might change unexpectedly in the future,
  potentially causing disruptions to any configuration relying on a stable or fixed IP address.

Explicit outbound access can be provided to a specific workload or application by:

- Deploying a NAT gateway into the subnet where the VM or VMSS is deployed.
- Deploying a Standard load balancer and configuring an outbound SNAT rule.

A public IP address can also be attached to a specific VM instance to provide explict outbound access.
However, attaching a public IP address to a VM also allows inbound access from the Internet which further compromises the security of the VM.

To provide outbound access to multiple workloads or applications a VWAN or hub and spoke network topology can be deployed.
See the Azure Cloud Adoption Framework (CAF) for guidance and a reference architecture for deploying network connectivity in Azure.

Note that there are limitations to this feature, so please refer to the documentation for detailed information.

## RECOMMENDATION

Consider using an explicit method of public connectivity for virtual machines.

## EXAMPLES

### Configure with Azure template

To configure virtual networks that pass this rule:

- For each subnet in defined the `properties.subnets` property:
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

- For each subnet in defined the `properties.subnets` property:
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
