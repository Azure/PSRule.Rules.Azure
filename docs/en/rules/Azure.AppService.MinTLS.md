---
severity: Critical
pillar: Security
category: Data protection
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.MinTLS/
ms-content-id: e19fbe7e-da05-47d4-8de1-2fdf52ada662
---

# App Service minimum TLS version

## SYNOPSIS

App Service should reject TLS versions older then 1.2.

## DESCRIPTION

The minimum version of TLS that Azure App Service accepts is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

App Service lets you disable outdated protocols and enforce TLS 1.2.
By default, a minimum of TLS 1.2 is enforced.

## RECOMMENDATION

Consider configuring the minimum supported TLS version to be 1.2.
Also consider using Azure Policy to audit or enforce this configuration.

## EXAMPLES

### Configure with Azure template

To deploy App Services that pass this rule:

- Set `properties.siteConfig.minTlsVersion` to `1.2`.

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

- Set `properties.siteConfig.minTlsVersion` to `1.2`.

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

- [Data encryption in Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Enforce TLS versions](https://docs.microsoft.com/azure/app-service/configure-ssl-bindings#enforce-tls-versions)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Insecure protocols](https://docs.microsoft.com/Azure/app-service/overview-security#insecure-protocols-http-tls-10-ftp)
- [Azure Policy built-in definitions for Azure App Service](https://docs.microsoft.com/azure/app-service/policy-reference)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.web/sites#siteconfig-object)
