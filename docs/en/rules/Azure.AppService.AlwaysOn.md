---
severity: Important
pillar: Performance Efficiency
category: Application design
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.AlwaysOn/
---

# Use App Service Always On

## SYNOPSIS

Configure Always On for App Service apps.

## DESCRIPTION

Azure App Service apps are automatically unloaded when there's no traffic.
Unloading apps reduces resource consumption when apps share a single App Services Plan.
After an app have been unloaded, the next web request will trigger a cold start of the app.

A cold start of the app can cause a noticeable performance issues and request timeouts.

Continuous WebJobs or WebJobs triggered with a CRON expression must use always on to start.

The Always On feature is implemented by the App Service load balancer,
periodically sending requests to the application root.

## RECOMMENDATION

Consider enabling Always On for each App Services app.

## EXAMPLES

### Configure with Azure template

To deploy App Services that pass this rule:

- Set `properties.siteConfig.alwaysOn` to `true`.

For example:

```json
{
    "type": "Microsoft.Web/sites",
    "apiVersion": "2021-02-01",
    "name": "[parameters('name')]",
    "location": "[parameters('location')]",
    "kind": "web",
    "properties": {
        "serverFarmId": "[resourceId('Microsoft.Web/serverfarms', parameters('planName'))]",
        "httpsOnly": true,
        "siteConfig": {
            "alwaysOn": true,
            "minTlsVersion": "1.2",
            "ftpsState": "FtpsOnly",
            "remoteDebuggingEnabled": false,
            "http20Enabled": true
        }
    },
    "tags": "[parameters('tags')]",
    "dependsOn": [
        "[resourceId('Microsoft.Web/serverfarms', parameters('planName'))]"
    ]
}
```

### Configure with Bicep

To deploy App Services that pass this rule:

- Set `properties.siteConfig.alwaysOn` to `true`.

For example:

```bicep
resource webApp 'Microsoft.Web/sites@2021-02-01' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    serverFarmId: appPlan.id
    httpsOnly: true
    siteConfig: {
      alwaysOn: true
      minTlsVersion: '1.2'
      ftpsState: 'FtpsOnly'
      remoteDebuggingEnabled: false
      http20Enabled: true
    }
  }
  tags: tags
}
```

## LINKS

- [Configure an App Service app](https://docs.microsoft.com/azure/app-service/configure-common#configure-general-settings)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.web/sites#siteconfig-object)
