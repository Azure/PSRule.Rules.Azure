---
severity: Important
pillar: Security
category: Security configuration
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.RemoteDebug/
---

# Disable App Service remote debugging

## SYNOPSIS

Disable remote debugging on App Service apps when not in use.

## DESCRIPTION

Remote debugging can be enabled on apps running within Azure App Services.

To enable remote debugging, App Service allows connectivity to additional ports.
While access to remote debugging ports is authenticated, the attack service for an app is increased.

## RECOMMENDATION

Consider disabling remote debugging when not in use.

## EXAMPLES

### Configure with Azure template

To deploy App Services that pass this rule:

- Set `properties.siteConfig.remoteDebuggingEnabled` to `false`.

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

- Set `properties.siteConfig.remoteDebuggingEnabled` to `false`.

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

- [Configure general settings](https://docs.microsoft.com/azure/app-service/configure-common#configure-general-settings)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.web/sites#siteconfig-object)
