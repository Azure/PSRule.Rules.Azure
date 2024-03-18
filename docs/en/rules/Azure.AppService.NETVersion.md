---
reviewed: 2024-03-19
severity: Important
pillar: Security
category: SE:02 Secured development lifecycle
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.NETVersion/
---

# Use a newer .NET version

## SYNOPSIS

Configure applications to use newer .NET versions.

## DESCRIPTION

Within a App Service app, the version of .NET used to run application/ site code is configurable.

Overtime, a specific version of .NET may become outdated and no longer supported by Microsoft.
This can lead to security vulnerabilities or are simply not able to use the latest security features.

.NET 6.0 and .NET 7.0 are approaching end of support.

## RECOMMENDATION

Consider updating the site to use a newer .NET version such as `v8.0`.

## EXAMPLES

### Configure with Azure template

To deploy App Services that pass this rule:

- For Windows-based plans:
  - Set the `properties.siteConfig.netFrameworkVersion` property to `v4.0` or `v8.0`.
- For Linux-based plans:
  - Set the `properties.siteConfig.linuxFxVersion` property to `DOTNET|8.0`.
    .NET Framework is not support on Linux-based plans.

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

To deploy App Services that pass this rule:

- For Windows-based plans:
  - Set the `properties.siteConfig.netFrameworkVersion` property to `v4.0` or `v8.0`.
- For Linux-based plans:
  - Set the `properties.siteConfig.linuxFxVersion` property to `DOTNET|8.0`.
    .NET Framework is not support on Linux-based plans.

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

### NOTE

.NET Framework 4.8 is only available on Windows-based plans.

## LINKS

- [SE:02 Secured development lifecycle](https://learn.microsoft.com/azure/well-architected/security/secure-development-lifecycle)
- [Configure ASP.NET](https://learn.microsoft.com/azure/app-service/configure-language-dotnet-framework)
- [Configure an ASP.NET Core app for Azure App Service](https://learn.microsoft.com/azure/app-service/configure-language-dotnetcore)
- [.NET Support Policy](https://dotnet.microsoft.com/platform/support/policy)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.web/sites)
