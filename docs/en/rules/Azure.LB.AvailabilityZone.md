---
reviewed: 2024-04-11
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: Load Balancer
resourceType: Microsoft.Network/loadBalancers
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.LB.AvailabilityZone/
---

# Internal load balancers should be zone-redundant

## SYNOPSIS

Load balancers deployed with Standard SKU should be zone-redundant for high availability.

## DESCRIPTION

A load balancer is an Azure service that distributes traffic among instances of a service in a backend pool (such as VMs).
Load balancers route traffic to healthy instances in the backend pool based on configured rules.
However if the load balancer itself becomes unavailable, traffic sent through the load balancer may become disrupted.

In a region that supports availability zones, Standard Load Balancers can be deployed across multiple zones (zone-redundant).
A zone-redundant Load Balancer allows traffic to be served by a single frontend IP address that can survive zone failure.

Also consider the data path to the backend pool, and ensure that the backend pool is deployed with zone-redundancy in mind.

In a region that supports availability zones, Standard Load Balancers should be deployed with zone-redundancy.

## RECOMMENDATION

Consider using load balancers deployed across at least two availability zones.

## EXAMPLES

### Configure with Azure template

To configure zone-redundancy for a load balancer.

- Set the `sku.name` property to `Standard`.
- Set the `properties.frontendIPConfigurations[*].zones` property to at least two availability zones.
  e.g. `1`, `2`, `3`.

For example:

```json
{
  "type": "Microsoft.Network/loadBalancers",
  "apiVersion": "2023-09-01",
  "name": "[parameters('lbName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard",
    "tier": "Regional"
  },
  "properties": {
    "frontendIPConfigurations": [
      {
        "name": "frontendIPConfig",
        "properties": {
          "privateIPAllocationMethod": "Dynamic",
          "subnet": {
            "id": "[reference(resourceId('Microsoft.Network/virtualNetworks', parameters('name')), '2023-09-01').subnets[1].id]"
          }
        },
        "zones": [
          "1",
          "2",
          "3"
        ]
      }
    ]
  }
}
```

### Configure with Bicep

To configure zone-redundancy for a load balancer.

- Set the `sku.name` property to `Standard`.
- Set the `properties.frontendIPConfigurations[*].zones` property to at least two availability zones.
  e.g. `1`, `2`, `3`.

For example:

```bicep
resource internal_lb 'Microsoft.Network/loadBalancers@2023-09-01' = {
  name: lbName
  location: location
  sku: {
    name: 'Standard'
    tier: 'Regional'
  }
  properties: {
    frontendIPConfigurations: [
      {
        name: 'frontendIPConfig'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: vnet.properties.subnets[1].id
          }
        }
        zones: [
          '1'
          '2'
          '3'
        ]
      }
    ]
  }
}
```

<!-- external:avm avm/res/network/load-balancer frontendIPConfigurations[*].zones -->

## NOTES

This rule applies to internal load balancers deployed with Standard SKU.
Internal load balancers do not have a public IP address and are used to load balance traffic inside a virtual network.

The `zones` property is not supported with:

- Public load balancers, which are load balancers with a public IP address.
  To address availability zones for public load balancers, use a Standard tier zone-redundant public IP address.
- Load balancers deployed with Basic SKU, which are not zone-redundant.

For regions that support availability zones, the `zones` property should be set to at least two zones.

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [What is Azure Load Balancer?](https://learn.microsoft.com/azure/load-balancer/load-balancer-overview)
- [Azure Load Balancer components](https://learn.microsoft.com/azure/load-balancer/components#frontend-ip-configurations)
- [Reliability in Load Balancer](https://learn.microsoft.com/azure/reliability/reliability-load-balancer)
- [Zone redundant load balancer](https://learn.microsoft.com/azure/reliability/reliability-load-balancer#zone-redundant-load-balancer)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/loadbalancers)
