---
reviewed: 2024-04-29
severity: Awareness
pillar: Performance Efficiency
category: PE:07 Code and infrastructure
resource: App Service
resourceType: Microsoft.Web/sites,Microsoft.Web/sites/slots
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

- Set the `properties.siteConfig.http20Enabled` property to `true`.

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

- Set the `properties.siteConfig.http20Enabled` property to `true`.

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

<!-- external:avm avm/res/web/site siteConfig.http20Enabled -->

## LINKS

- [PE:07 Code and infrastructure](https://learn.microsoft.com/azure/well-architected/performance-efficiency/optimize-code-infrastructure)
- [Service guide](https://learn.microsoft.com/azure/well-architected/service-guides/app-service-web-apps)
- [Configure an App Service app](https://learn.microsoft.com/azure/app-service/configure-common#configure-general-settings)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.web/sites)
