---
severity: Awareness
pillar: Performance Efficiency
category: Application design
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.HTTP2/
---

# Use HTTP/2 connections for App Service apps

## SYNOPSIS

Use HTTP/2 instead of HTTP/1.x to improve protocol efficiency.

## DESCRIPTION

Azure App Service has native support for HTTP/2, but by default it is disabled.
HTTP/2 offers a number of improvements over HTTP/1.1, including:

- Connections are fully multiplexed, instead of ordered and blocking.
- Connections are reused, reducing connection establishment overhead.
- Headers are compressed to reduce overhead.

## RECOMMENDATION

Consider using HTTP/2 for Azure Services apps to improve protocol efficiency.

## EXAMPLES

### Configure with Azure template

To deploy App Services that pass this rule:

- Set `properties.siteConfig.http20Enabled` to `true`.

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

- Set `properties.siteConfig.http20Enabled` to `true`.

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

- [Performance efficiency checklist](https://learn.microsoft.com/azure/architecture/framework/scalability/performance-efficiency)
- [Configure an App Service app](https://learn.microsoft.com/azure/app-service/configure-common#configure-general-settings)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.web/sites#siteconfig-object)
