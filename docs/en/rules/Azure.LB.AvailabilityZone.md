---
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: Load Balancer
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.LB.AvailabilityZone/
---

# Load balancers should be zone-redundant

## SYNOPSIS

Load balancers deployed with Standard SKU should be zone-redundant for high availability.

## DESCRIPTION

Load balancers using availability zones improve reliability and ensure availability during failure scenarios affecting a data center within a region.
A single zone redundant frontend IP address will survive zone failure.
The frontend IP may be used to reach all (non-impacted) backend pool members no matter the zone.
One or more availability zones can fail and the data path survives as long as one zone in the region remains healthy.

## RECOMMENDATION

Consider using zone-redundant load balancers deployed with Standard SKU.

## NOTES

This rule applies when analyzing resources deployed to Azure using *pre-flight* and *in-flight* data.

This rule fails when `"zones"` is constrained to a single(zonal) zone, and passes when set to `null`, `[]` or `["1", "2", "3"]`.

## EXAMPLES

### Configure with Azure template

To configure zone-redundancy for a load balancer.

- Set `sku.name` to `Standard`.
- Set `properties.frontendIPConfigurations[*].zones` to `["1", "2", "3"]`.

For example:

```json
{
    "apiVersion": "2020-07-01",
    "name": "[parameters('name')]",
    "type": "Microsoft.Network/loadBalancers",
    "location": "[parameters('location')]",
    "dependsOn": [],
    "tags": {},
    "properties": {
        "frontendIPConfigurations": [
            {
                "name": "frontend-ip-config",
                "properties": {
                    "privateIPAddress": null,
                    "privateIPAddressVersion": "IPv4",
                    "privateIPAllocationMethod": "Dynamic",
                    "subnet": {
                        "id": "/subscriptions/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx/resourceGroups/lb-rg/providers/Microsoft.Network/virtualNetworks/lb-vnet/subnets/default"
                    }
                },
                "zones": [
                    "1",
                    "2",
                    "3"
                ]
            }
        ],
        "backendAddressPools": [],
        "probes": [],
        "loadBalancingRules": [],
        "inboundNatRules": [],
        "outboundRules": []
    },
    "sku": {
        "name": "[parameters('sku')]",
        "tier": "[parameters('tier')]"
    }
}
```

### Configure with Bicep

To configure zone-redundancy for a load balancer.

- Set `sku.name` to `Standard`.
- Set `properties.frontendIPConfigurations[*].zones` to `['1', '2', '3']`.

For example:

```bicep
resource lb_001 'Microsoft.Network/loadBalancers@2021-02-01' = {
  name: lbName
  location: location
  sku: {
    name: 'Standard'
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

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Reliability in Load Balancer](https://learn.microsoft.com/azure/reliability/reliability-load-balancer)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/loadbalancers)
