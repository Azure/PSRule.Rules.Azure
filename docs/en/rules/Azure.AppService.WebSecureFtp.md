---
severity: Important
pillar: Security
category: Data protection
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.WebSecureFtp/
---

# Web apps disable insecure FTP

## SYNOPSIS

Web apps should disable insecure FTP and configure SFTP when required.

## DESCRIPTION

Azure App Service supports configuration of FTP and SFTP for uploading site content.
By default, both FTP and SFTP are enabled.
In many circumstances, use of FTP or SFTP is not required for automated deployments.

When interactive deployments are required consider using SFTP instead of FTP.
Use of FTP alone is not sufficient to prevent disclosure of sensitive information that may be transferred.

## RECOMMENDATION

Consider disabling insecure FTP and configure SFTP only when required.
Also consider using Azure Policy to audit or enforce this configuration.

## EXAMPLES

### Configure with Azure template

To deploy Web Apps that pass this rule:

- Set `properties.siteConfig.ftpsState` to `FtpsOnly` or `Disabled`.

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

- Set `properties.siteConfig.ftpsState` to `FtpsOnly` or `Disabled`.

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

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Deploy your app to Azure App Service using FTP/S](https://docs.microsoft.com/eazure/app-service/deploy-ftp)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.web/sites#siteproperties)
