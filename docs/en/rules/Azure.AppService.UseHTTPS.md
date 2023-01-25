---
severity: Important
pillar: Security
category: Data protection
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.UseHTTPS/
ms-content-id: b26053bc-db4a-487a-8fb1-11c438c8d493
---

# Enforce encrypted App Service connections

## SYNOPSIS

Azure App Service apps should only accept encrypted connections.

## DESCRIPTION

Azure App Service apps are configured by default to accept encrypted and unencrypted connections.
HTTP connections can be automatically redirected to use HTTPS when the _HTTPS Only_ setting is enabled.

Unencrypted communication to App Service apps could allow disclosure of information to an untrusted party.

## RECOMMENDATION

When access using unencrypted HTTP connection is not required consider enabling _HTTPS Only_.
Also consider using Azure Policy to audit or enforce this configuration.

## EXAMPLES

### Configure with Azure template

To deploy App Services that pass this rule:

- Set `properties.httpsOnly` to `true`.

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

- Set `properties.httpsOnly` to `true`.

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

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Enforce HTTPS](https://docs.microsoft.com/azure/app-service/configure-ssl-bindings#enforce-https)
- [Azure Policy built-in definitions for Azure App Service](https://docs.microsoft.com/azure/app-service/policy-reference)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.web/sites#siteproperties)
