---
reviewed: 2022-05-14
severity: Important
pillar: Security
category: Deployment
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.NETVersion/
---

# Use a newer .NET version

## SYNOPSIS

Configure applications to use newer .NET versions.

## DESCRIPTION

Within a App Service app, the version of .NET used to run application/ site code is configurable.
Older versions of .NET may not use the latest security features.

## RECOMMENDATION

Consider updating the site to use a newer .NET version such as `v6.0`.

## EXAMPLES

### Configure with Azure template

To deploy App Services that pass this rule:

- Set `properties.siteConfig.netFrameworkVersion` to a minimum of `v4.0`.

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
            "netFrameworkVersion": "v6.0"
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

- Set `properties.siteConfig.netFrameworkVersion` to a minimum of `v4.0`.

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
    }
  }
  tags: tags
}
```

## LINKS

- [Security design principles](https://docs.microsoft.com/azure/architecture/framework/security/security-principles#protect-against-code-level-vulnerabilities)
- [Set .NET Framework runtime version](https://docs.microsoft.com/azure/app-service/configure-language-dotnet-framework#set-net-framework-runtime-version)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.web/sites#siteconfig)
