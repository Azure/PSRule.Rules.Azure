---
severity: Important
pillar: Performance Efficiency
category: Application capacity
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.MinPlan/
ms-content-id: 97b58cfa-7b7e-4630-ac13-4596defe1795
---

# Use App Service production SKU

## SYNOPSIS

Use at least a Standard App Service Plan.

## DESCRIPTION

Azure App Services provide a range of different plans that can be used to scale your application.
Each plan provides different levels of performance and features.

To get you started a number of entry level plans are available.
The `Free`, `Shared`, and `Basic` plans can be used for limited testing and development.
However these plans are not suitable for production use.
Production workloads are best suited to standard and premium plans with `PremiumV3` the newest plan.

This rule does not apply to consumption or elastic App Services Plans used for Azure Functions.

## RECOMMENDATION

Consider using a standard or premium plan for hosting apps on Azure App Service.

## EXAMPLES

### Configure with Azure template

To deploy App Services Plans that pass this rule:

- Set `sku.tier` to a plan equal to or greater than `Standard`.
  For example: `PremiumV3`, `PremiumV2`, `Premium`, `Standard`

For example:

```json
{
    "type": "Microsoft.Web/serverfarms",
    "apiVersion": "2022-09-01",
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

- Set `sku.tier` to a plan equal to or greater than `Standard`.
  For example: `PremiumV3`, `PremiumV2`, `Premium`, `Standard`

For example:

```bicep
resource plan 'Microsoft.Web/serverfarms@2022-09-01' = {
  name: planName
  location: location
  sku: {
    name: 'S1'
    tier: 'Standard'
    capacity: 2
  }
}
```

## LINKS

- [Choose the right resources](https://learn.microsoft.com/azure/architecture/framework/scalability/design-capacity#choose-the-right-resources)
- [Azure App Service plan overview](https://learn.microsoft.com/azure/app-service/overview-hosting-plans)
- [Manage an App Service plan in Azure](https://learn.microsoft.com/azure/app-service/app-service-plan-manage)
- [Configure PremiumV3 tier for Azure App Service](https://learn.microsoft.com/azure/app-service/app-service-configure-premium-tier)
- [App Service pricing](https://azure.microsoft.com/pricing/details/app-service/windows/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.web/serverfarms)
