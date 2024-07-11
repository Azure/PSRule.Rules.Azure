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

App service plans supports the use of availability zones to provide zone redundancy for the applications running on the instances within the plan. Zone redundancy enhances the resiliency and high availability of the app service plan by deploying instances across data centers in physically separated zones.

App service plans use auto-scaling to manage the number of instances based on demand. The following rules apply when scaling a zone-redundant app service plan:

- Minimum Instance Count: The app service plan must have a minimum of 3 instances to support zone redundancy.
 - If you enable availability zones but specify a capacity less than 3, the platform will enforce a minimum instance count of 3.
- Even Distribution: If the instance count is larger than 3 and divisible by 3, instances are evenly distributed across the three zones.
- Partial Distribution: Instance counts beyond 3*N are spread across the remaining one or two zones to ensure balanced distribution.

**Important** Configuring zone redundancy with per-application scaling is possible but may increase costs and administrative overhead.
When `perSiteScaling` is enabled, each application can have its own scaling rules and run on dedicated instances. To maintain zone redundancy, it is crucial that each application’s scaling rules ensure a minimum of 3 instances.
Without explicitly configuring this minimum, the application may not meet the zone redundancy requirement.

## RECOMMENDATION

To improve the resiliency of app service plan instances against zone failures, it is recommended to use availability zones. This configuration enhances fault tolerance and ensures continued operation even if one zone experiences an outage.

## EXAMPLES

### Configure with Azure template

To configure a zone-redundant app service plan:

- Set the `properties.ZoneRedundant` property to `true`.

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
    "ZoneRedundant": true
  }
}
```

### Configure with Bicep

To configure a zone-redundant app service plan:

- Set the `properties.ZoneRedundant` property to `true`.

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
