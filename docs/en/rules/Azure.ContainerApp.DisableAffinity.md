---
reviewed: 2024-04-07
severity: Important
pillar: Performance Efficiency
category: PE:05 Scaling and partitioning
resource: Container App
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.DisableAffinity/
---

# Disable session affinity

## SYNOPSIS

Disable session affinity to prevent unbalanced distribution.

## DESCRIPTION

Container apps allows you to configure session affinity (sticky sessions).
When enabled, this feature route requests from the same client to the same replica.
This feature might be useful for stateful applications that require a consistent connection to the same replica.

However, for stateless applications there is drawbacks to using session affinity.
As connections are opened and closed, a subset of replicas might become overloaded with requests, while others are dormant.
This can lead to: poor performance and resource utilization; less predictable scaling.

## RECOMMENDATION

Consider using stateful application design and disabling session affinity to evenly distribute requests across each replica.

## EXAMPLES

### Configure with Azure template

To deploy Container Apps that pass this rule:

- Set `properties.configuration.ingress.stickySessions.affinity` to `none` or don't specify the property at all.

For example:

```json
{
  "type": "Microsoft.App/containerApps",
  "apiVersion": "2023-05-01",
  "name": "[parameters('appName')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "environmentId": "[resourceId('Microsoft.App/managedEnvironments', parameters('envName'))]",
    "template": {
      "revisionSuffix": "[parameters('revision')]",
      "containers": "[variables('containers')]",
      "scale": {
        "minReplicas": 2
      }
    },
    "configuration": {
      "ingress": {
        "allowInsecure": false,
        "stickySessions": {
          "affinity": "none"
        }
      }
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.App/managedEnvironments', parameters('envName'))]"
  ]
}
```

### Configure with Bicep

To deploy Container Apps that pass this rule:

- Set `properties.configuration.ingress.stickySessions.affinity` to `none` or don't specify the property at all.

For example:

```bicep
resource containerApp 'Microsoft.App/containerApps@2023-05-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    environmentId: containerEnv.id
    template: {
      revisionSuffix: revision
      containers: containers
      scale: {
        minReplicas: 2
      }
    }
    configuration: {
      ingress: {
        allowInsecure: false
        stickySessions: {
          affinity: 'none'
        }
      }
    }
  }
}
```

### NOTES

This rule may generate false positive results for stateful applications.

## LINKS

- [PE:05 Scaling and partitioning](https://learn.microsoft.com/azure/well-architected/performance-efficiency/scale-partition)
- [Session Affinity in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/sticky-sessions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps#ingressstickysessions)
