---
severity: Important
pillar: Performance Efficiency
category: Design for performance efficiency
resource: Container App
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ContainerApp.DisableAffinity/
---

# Disable session affinity

## SYNOPSIS

Disable session affinity to prevent unbalanced distribution.

## DESCRIPTION

Container apps allows you to configure session affinity (sticky sessions).
When enabled, this feature route requests from the same client to the same replica.

This feature might be useful for stateful applications that require a consistent connection to the same replica. However, if your application does not store large amounts of state or cached data in memory (stateless application design pattern), session affinity might decrease your throughput because one replica could get overloaded with requests, while others are dormant.

## RECOMMENDATION

Consider disabling session affinity to evenly distribute requests across each replica.

## EXAMPLES

### Configure with Azure template

To deploy Container Apps that pass this rule:

- Set `properties.configuration.ingress.stickySessions.affinity` to `none` or don't specify the property at all.

For example:

```json
{
  "type": "Microsoft.App/containerApps",
  "apiVersion": "2022-10-01",
  "name": "[parameters('appName')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned",
    "userAssignedIdentities": {}
  },
  "properties": {
    "environmentId": "[parameters('environmentId')]",
    "template": {
      "revisionSuffix": "",
      "containers": "[variables('containers')]"
    },
    "configuration": {
      "ingress": {
        "external": false,
        "stickySessions": {
          "affinity": "None"
        }
      }
    }
  }
}
```

### Configure with Bicep

To deploy Container Apps that pass this rule:

- Set `properties.configuration.ingress.stickySessions.affinity` to `none` or don't specify the property at all.

For example:

```bicep
resource containerApp 'Microsoft.App/containerApps@2022-10-01' = {
  name: appName
  location: location
  identity: {
    type: 'SystemAssigned'
    userAssignedIdentities: {}
  }
   properties: {
    environmentId: environmentId
    template: {
      revisionSuffix: ''
      containers: containers
    }
    configuration: {
      ingress: {
        external: false
        stickySessions: {
          affinity: 'none'
      }
    }
  }
}
```

## LINKS

- [Avoid a requirement to store server-side session state](https://learn.microsoft.com/azure/well-architected/scalability/design-checklist#implementation)
- [Session affinity](https://learn.microsoft.com/azure/well-architected/scalability/design-efficiency#improve-scalability-with-session-affinity)
- [Session Affinity in Azure Container Apps](https://learn.microsoft.com/azure/container-apps/sticky-sessions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.app/containerapps#ingressstickysessions)
