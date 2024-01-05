---
reviewed: 2023-02-18
severity: Important
pillar: Cost Optimization
category: CO:14 Consolidation
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoor.State/
---

# Enable Front Door Classic instance

## SYNOPSIS

Enable Azure Front Door Classic instance.

## DESCRIPTION

The operational state of a Front Door Classic instance is configurable, either enabled or disabled.
By default, a Front Door is enabled.

Optionally, a Front Door Classic instance may be disabled to temporarily prevent traffic being processed.

## RECOMMENDATION

Consider enabling the Front Door service or remove the instance if it is no longer required.
This applies to Azure Front Door Classic instances only.

## EXAMPLES

### Configure with Azure template

To deploy a Front Door resource that passes this rule:

- Set the `properties.enabledState` property to `Enabled`.

For example:

```json
{
  "type": "Microsoft.Network/frontDoors",
  "apiVersion": "2021-06-01",
  "name": "[parameters('name')]",
  "location": "global",
  "properties": {
    "enabledState": "Enabled",
    "frontendEndpoints": "[variables('frontendEndpoints')]",
    "loadBalancingSettings": "[variables('loadBalancingSettings')]",
    "backendPools": "[variables('backendPools')]",
    "healthProbeSettings": "[variables('healthProbeSettings')]",
    "routingRules": "[variables('routingRules')]"
  }
}
```

### Configure with Bicep

To deploy a Front Door resource that passes this rule:

- Set the `properties.enabledState` property to `Enabled`.

For example:

```bicep
resource afd_classic 'Microsoft.Network/frontDoors@2021-06-01' = {
  name: name
  location: 'global'
  properties: {
    enabledState: 'Enabled'
    frontendEndpoints: frontendEndpoints
    loadBalancingSettings: loadBalancingSettings
    backendPools: backendPools
    healthProbeSettings: healthProbeSettings
    routingRules: routingRules
  }
}
```

## LINKS

- [CO:14 Consolidation](https://learn.microsoft.com/azure/well-architected/cost-optimization/consolidation)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/frontdoors)
