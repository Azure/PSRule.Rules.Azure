---
severity: Important
pillar: Security
category: SE:07 Encryption
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

- Set the `properties.siteConfig.ftpsState` property to `FtpsOnly` or `Disabled`.

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

To deploy Web Apps that pass this rule:

- Set the `properties.siteConfig.ftpsState` property to `FtpsOnly` or `Disabled`.

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

<!-- external:avm avm/res/web/site siteConfig.ftpsState -->

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [App Service apps should require FTPS only](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/App%20Service/AuditFTPS_WebApp_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/4d24b6d4-5e53-4a4f-a7f4-618fa573ee4b`
- [App Service app slots should require FTPS only](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/App%20Service/AuditFTPS_WebApp_Slot_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/c285a320-8830-4665-9cc7-bbd05fc7c5c0`
- [Function apps should require FTPS only](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/App%20Service/AuditFTPS_FunctionApp_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/399b2637-a50f-4f95-96f8-3a145476eb15`
- [Function app slots should require FTPS only](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/App%20Service/AuditFTPS_FunctionApp_Slot_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/e1a09430-221d-4d4c-a337-1edb5a1fa9bb`
- [[Deprecated]: FTPS only should be required in your API App](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/App%20Service/AuditFTPS_ApiApp_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/9a1b8c48-453a-4044-86c3-d8bfd823e4f5`

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#data-in-transit)
- [Deploy your app to Azure App Service using FTP/S](https://learn.microsoft.com/Azure/app-service/deploy-ftp#enforce-ftps)
- [Insecure protocols](https://learn.microsoft.com/Azure/app-service/overview-security#insecure-protocols-http-tls-10-ftp)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.web/sites)
