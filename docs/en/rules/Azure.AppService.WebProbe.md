---
severity: Important
pillar: Reliability
category: Load balancing and failover
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.WebProbe/
---

# Web apps use health probes

## SYNOPSIS

Configure and enable instance health probes.

## DESCRIPTION

Azure App Service monitors a specific path for each web app instance to determine health status.
The monitored path should implement functional checks to determine if the app is performing correctly.
The checks should include dependencies including those that may not be regularly called.

Regular checks of the monitored path allow Azure App Service to route traffic based on availability.

## RECOMMENDATION

Consider configuring a health probe to monitor instance availability.

## EXAMPLES

### Configure with Azure template

To deploy Web Apps that pass this rule:

- Set `properties.siteConfig.healthCheckPath` to a valid application path such as `/healthz`.

For example:

```json
{
    "type": "Microsoft.Web/sites",
    "apiVersion": "2021-03-01",
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
            "ftpsState": "FtpsOnly",
            "remoteDebuggingEnabled": false,
            "http20Enabled": true,
            "netFrameworkVersion": "v6.0",
            "healthCheckPath": "/healthz"
        }
    },
    "tags": "[parameters('tags')]",
    "dependsOn": [
        "[resourceId('Microsoft.Web/serverfarms', parameters('planName'))]"
    ]
}
```

### Configure with Bicep

To deploy Web Apps that pass this rule:

- Set `properties.siteConfig.healthCheckPath` to a valid application path such as `/healthz`.

For example:

```bicep
resource webApp 'Microsoft.Web/sites@2021-03-01' = {
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
      ftpsState: 'FtpsOnly'
      remoteDebuggingEnabled: false
      http20Enabled: true
      netFrameworkVersion: 'v6.0'
      healthCheckPath: '/healthz'
    }
  }
  tags: tags
}
```

## LINKS

- [Creating good health probes](https://docs.microsoft.com/azure/architecture/framework/resiliency/monitor-model#create-good-health-probes)
- [Route traffic to healthy instances (App Service)](https://docs.microsoft.com/azure/azure-monitor/platform/autoscale-get-started#route-traffic-to-healthy-instances-app-service)
- [Health Check is now Generally Available](https://azure.github.io/AppService/2020/08/24/healthcheck-on-app-service.html)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.web/sites#siteproperties)
