---
reviewed: 2025-05-30
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Virtual Network
resourceType: Microsoft.Network/virtualNetworks,Microsoft.Network/virtualNetworks/subnets
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNET.PrivateSubnet/
---

# Virtual Network subnet default outbound access is enabled

## SYNOPSIS

Subnets that allow direct outbound access to the Internet may expose virtual machines to increased security risks.

## DESCRIPTION

By default, virtual machines (VMs) and virtual machine scale sets (VMSS) configured with the uniform orchestration mode
have outbound connectivity to the Internet.
However, the path that network traffic takes is determined by many factors including firewall rules and routing.

When default outbound is enabled traffic to the Internet is automatically routing via a shared NAT pool.
The IP address used by the shared NAT pool is used across multiple customers, and is subject to change.

As an additional security feature, Azure virtual network (VNET) subnets support disabling the default outbound Internet access.
Additionally, default outbound access for new VMs and VMSS is scheduled for retirement in September 2025.

Instead of using default outbound access, consider using an explicit method of public connectivity for virtual machines.
Explicit outbound access has the following benefits:

- **Security** &mdash; Outbound Internet access can be used to transfer data or control out of your organization.
  Controlling outbound access allows you to make an explicit choice about which workloads require this vs those that don't.
- **Ownership and stability** &mdash; The default outbound access IP is managed by Microsoft and used by multiple customers.
  As a result, you can't assume use the address for network security rules and the address might change unexpectedly in
  the future, potentially causing disruptions to any configuration relying on a stable or fixed IP address.
  Controlling outbound access allows you to use a stable IP address or group of IP addresses that you manage.

Explicit outbound access can be provided to a specific workload or application by:

- Deploying a NAT gateway into the subnet where the VM or VMSS is deployed.
- Deploying a Standard load balancer and configuring an outbound SNAT rule.

A public IP address can also be attached to a specific VM to provide explicit outbound access.
However, attaching a public IP address to a VM also allows inbound access from the Internet which further compromises
the security of the VM.

To provide outbound access to multiple workloads or applications a VWAN or hub and spoke network topology can be deployed.
See the Azure Cloud Adoption Framework (CAF) for guidance and a reference architecture for deploying network
connectivity in Azure.

Note that there are limitations to this feature, so please refer to the documentation for detailed information.

## RECOMMENDATION

Consider disabling default outbound access for all subnets in a virtual network.
Additionally, consider using an explicit method of connectivity for instances that require outbound access to the Internet.

## EXAMPLES

### Configure with Bicep

To configure virtual networks that pass this rule:

- For each subnet in defined the `properties.subnets` property:
  - Set the `properties.defaultOutboundAccess` property to `false`.

For example:

```bicep
resource vnet 'Microsoft.Network/virtualNetworks@2024-05-01' = {
  name: name
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    dhcpOptions: {
      dnsServers: [
        '10.0.1.4'
        '10.0.1.5'
      ]
    }
    encryption: {
      enabled: true
      enforcement: 'AllowUnencrypted'
    }
    subnets: [
      {
        name: 'GatewaySubnet'
        properties: {
          addressPrefix: '10.0.0.0/24'
          defaultOutboundAccess: false
        }
      }
      {
        name: 'snet-001'
        properties: {
          addressPrefix: '10.0.1.0/24'
          defaultOutboundAccess: false
          networkSecurityGroup: {
            id: nsgId
          }
        }
      }
      {
        name: 'snet-002'
        properties: {
          addressPrefix: '10.0.2.0/24'
          defaultOutboundAccess: false
          delegations: [
            {
              name: 'HSM'
              properties: {
                serviceName: 'Microsoft.HardwareSecurityModules/dedicatedHSMs'
              }
            }
          ]
        }
      }
    ]
  }
}
```

<!-- external:avm avm/res/network/virtual-network subnets[*].defaultOutboundAccess -->

### Configure with Azure template

To configure virtual networks that pass this rule:

- For each subnet in defined the `properties.subnets` property:
  - Set the `properties.defaultOutboundAccess` property to `false`.

For example:

```json
{
  "type": "Microsoft.Network/virtualNetworks",
  "apiVersion": "2024-05-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "addressSpace": {
      "addressPrefixes": [
        "10.0.0.0/16"
      ]
    },
    "dhcpOptions": {
      "dnsServers": [
        "10.0.1.4",
        "10.0.1.5"
      ]
    },
    "encryption": {
      "enabled": true,
      "enforcement": "AllowUnencrypted"
    },
    "subnets": [
      {
        "name": "GatewaySubnet",
        "properties": {
          "addressPrefix": "10.0.0.0/24",
          "defaultOutboundAccess": false
        }
      },
      {
        "name": "snet-001",
        "properties": {
          "addressPrefix": "10.0.1.0/24",
          "defaultOutboundAccess": false,
          "networkSecurityGroup": {
            "id": "[parameters('nsgId')]"
          }
        }
      },
      {
        "name": "snet-002",
        "properties": {
          "addressPrefix": "10.0.2.0/24",
          "defaultOutboundAccess": false,
          "delegations": [
            {
              "name": "HSM",
              "properties": {
                "serviceName": "Microsoft.HardwareSecurityModules/dedicatedHSMs"
              }
            }
          ]
        }
      }
    ]
  }
}
```

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Default outbound access](https://learn.microsoft.com/azure/virtual-network/ip-services/default-outbound-access)
- [Plan for inbound and outbound internet connectivity](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/plan-for-inbound-and-outbound-internet-connectivity)
- [What is Azure NAT Gateway?](https://learn.microsoft.com/azure/nat-gateway/nat-overview)
- [Azure deployment reference - Virtual Network](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks)
- [Azure deployment reference - Subnet](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks/subnets)
