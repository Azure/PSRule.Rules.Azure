---
severity: Awareness
pillar: Reliability
category: RE:05 Redundancy
resource: Virtual Network
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VNET.FirewallSubnetNAT/
---

# Outbound access

## SYNOPSIS

Zonal-deployed Azure Firewalls should consider using an Azure NAT Gateway for outbound access.

## DESCRIPTION

Azure Firewall can be deployed with up to 250 public IP addresses, each providing 2,496 SNAT ports. This setup offers a maximum of 1,248,000 SNAT ports.

Managing a large number of public IP addresses comes with challenges, particularly regarding downstream IP address filtering requirements. When Azure Firewall is associated with multiple public IP addresses, these filtering requirements must be applied to all associated addresses. 
Even when using Public IP address prefixes, associating 250 public IP addresses requires managing 16 public IP address prefixes on the downstream side.

A more efficient solution for scaling and dynamically allocating outbound SNAT ports is to use an Azure NAT Gateway:

- High Capacity: Each public IP address on a NAT Gateway provides 64,512 SNAT ports, and up to 16 public IP addresses can be associated, resulting in up to 1,032,192 SNAT ports.
- Dynamic Allocation: SNAT ports are dynamically allocated at the subnet level, making all provided SNAT ports available on demand for outbound connectivity.

This configuration simplifies management for downstream systems, as it requires handling only up to 16 public IP addresses.

When an Azure NAT Gateway is associated with an Azure Firewall subnet:

- All outbound internet traffic uses the NAT Gateway’s public IP addresses.
  - Response traffic for outbound flows also passes through the NAT Gateway.
- If multiple public IP addresses are associated with the NAT Gateway, the IP address used is randomly selected, and specific addresses cannot be chosen.

**Important** Azure NAT Gateway supports only zonal deployment. Therefore, only zonal-deployed Azure Firewalls should utilize Azure NAT Gateway.
Azure Firewalls with zone redundancy might face reduced availability if a NAT Gateway is deployed in a single zone that experiences a failure.

## RECOMMENDATION

Consider using an Azure NAT gateway for zonal-deployed Azure Firewalls for outbound access.

## EXAMPLES

### Configure with Azure template

To configure virtual networks that pass this rule:

- For the `AzureFirewallSubnet` subnet in defined the `properties.subnets` property:
  - Set the `properties.natGateway.id` property to the resource id of the NAT gateway.

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
        "name": "AzureFirewallSubnet",
        "properties": {
          "addressPrefix": "10.0.0.0/26",
          "natGateway": {
            "id": "[parameters('natGatewayResourceId')]",
          }
        }
      }
    ]
  }
}
```

### Configure with Bicep

To configure virtual networks that pass this rule:

- For the `AzureFirewallSubnet` subnet in defined the `properties.subnets` property:
  - Set the `properties.natGateway.id` property to the resource id of the NAT gateway.

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
        name: 'AzureFirewallSubnet'
        properties: {
          addressPrefix: '10.0.0.0/26'
           natGateway: {
            id: natGatewayResourceId
          }
        }
      }
    ]
  }
}
```

## LINKS

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [Scale SNAT ports with Azure NAT Gateway](https://learn.microsoft.com/azure/firewall/integrate-with-nat-gateway)
- [Plan for inbound and outbound internet connectivity](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/plan-for-inbound-and-outbound-internet-connectivity)
- [Azure deployment reference - Virtual Network](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks)
- [Azure deployment reference - Subnet](https://learn.microsoft.com/azure/templates/microsoft.network/virtualnetworks/subnets)
