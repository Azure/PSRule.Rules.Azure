---
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Load Balancer
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.LB.StandardSKU/
---

# Load balancers should use Standard SKU

## SYNOPSIS

Load balancers should be deployed with Standard SKU for production workloads.

## DESCRIPTION

Standard Load Balancer enables you to scale your applications and create high availability for small scale deployments to large and complex multi-zone architectures.
It supports inbound as well as outbound connections, provides low latency and high throughput, and scales up to millions of flows for all TCP and UDP applications.
It enables Availability Zones with zone-redundant and zonal front ends as well as cross-zone load balancing for public and internal scenarios.
You can scale Network Virtual Appliance scenarios and make them more resilient by using internal HA Ports load balancing rules.
It also provides new diagnostics insights with multi-dimensional metrics in Azure Monitor.

## RECOMMENDATION

Consider using Standard SKU for load balancers deployed in production.

## EXAMPLES

### Configure with Azure template

To configure Standard SKU for a load balancer.

- Set `sku.name` to `Standard`.

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
        "name": "Standard",
        "tier": "[parameters('tier')]"
    }
}
```

### Configure with Bicep

To configure Standard SKU for a load balancer.

- Set `sku.name` to `Standard`.

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

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Why use Azure Load Balancer?](https://learn.microsoft.com/azure/load-balancer/load-balancer-overview#why-use-azure-load-balancer)
- [Azure Load Balancer SKUs](https://learn.microsoft.com/azure/load-balancer/skus)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/loadbalancers)
