---
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.WebProbePath/
---

# Web apps use a dedicated health probe path

## SYNOPSIS

Configure a dedicated path for health probe requests.

## DESCRIPTION

Azure App Service monitors a specific path for each web app instance to determine health status.
The monitored path should implement functional checks to determine if the app is performing correctly.
The checks should include dependencies including those that may not be regularly called.

Regular checks of the monitored path allow Azure App Service to route traffic based on availability.

## RECOMMENDATION

Consider using a dedicated health probe endpoint that implements functional checks.

## EXAMPLES

### Configure with Azure template

To deploy Web Apps that pass this rule:

- Set the `properties.siteConfig.healthCheckPath` property to a dedicated application path such as `/healthz`.

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

To deploy Web Apps that pass this rule:

- Set the `properties.siteConfig.healthCheckPath` property to a dedicated application path such as `/healthz`.

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

<!-- external:avm avm/res/web/site siteConfig.healthCheckPath -->

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Creating good health probes](https://learn.microsoft.com/azure/architecture/framework/resiliency/monitor-model#create-good-health-probes)
- [Health Check is now Generally Available](https://azure.github.io/AppService/2020/08/24/healthcheck-on-app-service.html)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.web/sites)
