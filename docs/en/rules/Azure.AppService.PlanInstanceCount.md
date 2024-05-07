---
severity: Important
pillar: Reliability
category: Resiliency and dependencies
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.PlanInstanceCount/
ms-content-id: 6f3eff05-1bd0-4c82-a5a5-573fc8e0beda
---

# Use two or more App Service Plan instances

## SYNOPSIS

App Service Plan should use a minimum number of instances for failover.

## DESCRIPTION

App Services Plans provides a configurable number of instances that will run apps.
When a single instance is configured your app may be temporarily unavailable during unplanned interruptions.
In most circumstances, Azure will self heal faulty app service instances automatically.
However during this time there may interruptions to your workload.

This rule does not apply to consumption or elastic App Services Plans.

## RECOMMENDATION

Consider using an App Service Plan with at least two (2) instances.

## EXAMPLES

### Configure with Azure template

To deploy App Services Plans that pass this rule:

- Set `sku.capacity` to `2` or more.

For example:

```json
{
    "type": "Microsoft.Web/serverfarms",
    "apiVersion": "2021-01-15",
    "name": "[parameters('planName')]",
    "location": "[parameters('location')]",
    "sku": {
        "name": "S1",
        "tier": "Standard",
        "capacity": 2
    }
}
```

### Configure with Bicep

To deploy App Services Plans that pass this rule:

- Set `sku.capacity` to `2` or more.

For example:

```bicep
resource appPlan 'Microsoft.Web/serverfarms@2021-01-15' = {
  name: planName
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
    capacity: 2
  }
}
```

<!-- external:avm avm/res/web/serverfarm skuCapacity -->

## LINKS

- [Resiliency and dependencies](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-resiliency)
- [Get started with Autoscale in Azure](https://learn.microsoft.com/azure/azure-monitor/autoscale/autoscale-get-started)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.web/serverfarms)
