---
severity: Awareness
pillar: Performance Efficiency
category: PE:05 Scaling and partitioning
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.ARRAffinity/
ms-content-id: 3f07def6-6e5e-4f87-8b5d-3a0baf6631e5
---

# Disable Application Request Routing

## SYNOPSIS

Disable client affinity for stateless services.

## DESCRIPTION

Azure App Service apps use Application Request Routing (ARR) by default.
ARR uses a cookie to route subsequent client requests back to the same instance when an app is scaled to two or more instances.
This benefits stateful applications, which may hold session information in instance memory.

For stateless applications, disabling ARR allows Azure App Service more evenly distribute load.

## RECOMMENDATION

Azure App Service sites make use of Application Request Routing (ARR) by default.
Consider disabling ARR affinity for stateless applications.

## EXAMPLES

### Configure with Azure template

To deploy App Services that pass this rule:

- Set the `properties.clientAffinityEnabled` property to `false`.

For example:

```json
{
  "type": "Microsoft.Web/sites",
  "apiVersion": "2023-01-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  },
  "kind": "web",
  "properties": {
    "serverFarmId": "[resourceId('Microsoft.Web/serverfarms', parameters('planName'))]",
    "httpsOnly": true,
    "clientAffinityEnabled": false,
    "siteConfig": {
      "alwaysOn": true,
      "minTlsVersion": "1.2",
      "ftpsState": "Disabled",
      "remoteDebuggingEnabled": false,
      "http20Enabled": true,
      "netFrameworkVersion": "v8.0",
      "healthCheckPath": "/healthz",
      "metadata": [
        {
          "name": "CURRENT_STACK",
          "value": "dotnet"
        }
      ]
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.Web/serverfarms', parameters('planName'))]"
  ]
}
```

### Configure with Bicep

To deploy App Services that pass this rule:

- Set the `properties.clientAffinityEnabled` property to `false`.

For example:

```bicep
resource web 'Microsoft.Web/sites@2023-01-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  kind: 'web'
  properties: {
    serverFarmId: plan.id
    httpsOnly: true
    clientAffinityEnabled: false
    siteConfig: {
      alwaysOn: true
      minTlsVersion: '1.2'
      ftpsState: 'Disabled'
      remoteDebuggingEnabled: false
      http20Enabled: true
      netFrameworkVersion: 'v8.0'
      healthCheckPath: '/healthz'
      metadata: [
        {
          name: 'CURRENT_STACK'
          value: 'dotnet'
        }
      ]
    }
  }
}
```

<!-- external:avm avm/res/web/site clientAffinityEnabled -->

## LINKS

- [PE:05 Scaling and partitioning](https://learn.microsoft.com/azure/well-architected/performance-efficiency/scale-partition)
- [Configure an App Service app](https://learn.microsoft.com/azure/app-service/configure-common#configure-general-settings)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.web/serverfarms)
