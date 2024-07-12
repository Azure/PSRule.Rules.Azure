---
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.AvailabilityZone/
---

# Deploy app service plan instances using availability zones

## SYNOPSIS

Deploy app service plan instances using availability zones in supported regions to ensure high availability and resilience.

## DESCRIPTION

App Service plans support zone redundancy, which distributes your application running within the plan across Availablity Zones.
Each Availability Zone is a group of phyiscally separated data centers.
Deploying your application with zone redundancy:

- Scales your plan to a minimum of 3 instances in a highly available configuration.
  Additional instances can be added manually or on-demand by using autoscale.
- Improves the resiliency against service disruptions or issues affecting a single zone.

Additionally:

- **Even Distribution**: If the instance count is larger than 3 and divisible by 3, instances are evenly distributed across the three zones.
- **Partial Distribution**: Instance counts beyond 3*N are spread across the remaining one or two zones to ensure balanced distribution.

**Important** Configuring zone redundancy with per-application scaling is possible but may increase costs and administrative overhead.
When `perSiteScaling` is enabled, each application can have its own scaling rules and run on dedicated instances.
To maintain zone redundancy, it is crucial that each application’s scaling rules ensure a minimum of 3 instances.
Without explicitly configuring this minimum, the application may not meet the zone redundancy requirement.

## RECOMMENDATION

Consider using enabling zone redundancy using availability zones to improve the resiliency of your solution.

## EXAMPLES

### Configure with Azure template

To configure a zone-redundant app service plan:

- Set the `properties.zoneRedundant` property to `true`.

For example:

```json
{
  "type": "Microsoft.Web/serverfarms",
  "apiVersion": "2022-09-01",
  "name": "[parameters('planName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "P1v3",
    "tier": "PremiumV3",
    "size": "P1v3",
    "family": "Pv3",
    "capacity": 3
  },
  "properties": {
    "zoneRedundant": true
  }
}
```

### Configure with Bicep

To configure a zone-redundant app service plan:

- Set the `properties.zoneRedundant` property to `true`.

For example:

```bicep
resource plan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: name
  location: location
  sku: {
    name: 'P1v3'
    tier: 'PremiumV3'
    size: 'P1v3'
    family: 'Pv3'
    capacity: 3
  }
  properties: {
    zoneRedundant: true
  }
}
```

## NOTES

Zone-redundancy is only supported for the `PremiumV2`, `PremiumV3` and `ElasticPremium` SKU tiers.

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Reliability in Azure App Service](https://learn.microsoft.com/azure/reliability/reliability-app-service)
- [Availability zone support](https://learn.microsoft.com/azure/reliability/reliability-app-service#availability-zone-support)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.web/serverfarms)
