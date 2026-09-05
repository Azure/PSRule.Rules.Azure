---
severity: Important
pillar: Reliability
category: Resiliency and dependencies
resource: App Service
resourceType: Microsoft.Web/serverfarms
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.PlanInstanceCount/
ms-content-id: 6f3eff05-1bd0-4c82-a5a5-573fc8e0beda
---

# Use two or more App Service Plan instances

## SYNOPSIS

App Service Plan should use a minimum number of instances for failover.

## DESCRIPTION

App Service Plans provide a configurable number of instances that run apps.
When a single instance is configured, your app may be temporarily unavailable during unplanned interruptions.
In most circumstances, Azure will self-heal faulty App Service instances automatically.
However, during this time there may be interruptions to your workload.

For higher resiliency in supported regions, App Service Plans can also use availability zones (zone redundancy).
Zone redundancy distributes plan instances across physically separated zones and scales the plan to a minimum of three instances.
See [Azure.AppService.AvailabilityZone](Azure.AppService.AvailabilityZone.md) for zone-redundancy configuration.
Use at least two instances for basic failover even when zone redundancy is not enabled.

This rule does not apply to consumption or elastic App Service Plans.

## RECOMMENDATION

Consider using an App Service Plan with at least two (2) instances.
When you enable zone redundancy, plan for at least three (3) instances so the workload stays aligned with availability-zone guidance.

## EXAMPLES

### Configure with Azure template

To deploy App Service Plans that pass this rule:

- Set `sku.capacity` to `2` or more.

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
    "capacity": 2
  }
}
```

### Configure with Bicep

To deploy App Service Plans that pass this rule:

- Set `sku.capacity` to `2` or more.

For example:

```bicep
resource appPlan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: planName
  location: location
  sku: {
    name: 'P1v3'
    tier: 'PremiumV3'
    size: 'P1v3'
    family: 'Pv3'
    capacity: 2
  }
}
```

<!-- external:avm avm/res/web/serverfarm skuCapacity -->

## LINKS

- [Resiliency and dependencies](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-resiliency)
- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Reliability in Azure App Service](https://learn.microsoft.com/azure/reliability/reliability-app-service)
- [Get started with Autoscale in Azure](https://learn.microsoft.com/azure/azure-monitor/autoscale/autoscale-get-started)
- [Azure.AppService.AvailabilityZone](Azure.AppService.AvailabilityZone.md)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.web/serverfarms)
