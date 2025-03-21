---
severity: Important
pillar: Security
category: SE:07 Encryption
resource: App Service
resourceType: Microsoft.Web/sites,Microsoft.Web/sites/slots
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.UseHTTPS/
ms-content-id: b26053bc-db4a-487a-8fb1-11c438c8d493
---

# App Service allows unencrypted traffic

## SYNOPSIS

Unencrypted communication could allow disclosure of information to an untrusted party.

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

- Set the `properties.httpsOnly` property to `true`.

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

- Set the `properties.httpsOnly` property to `true`.

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

<!-- external:avm avm/res/web/site httpsOnly -->

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#encrypt-data-in-transit)
- [DP-3: Encrypt sensitive data in transit](https://learn.microsoft.com/security/benchmark/azure/baselines/app-service-security-baseline#dp-3-encrypt-sensitive-data-in-transit)
- [Enforce HTTPS](https://learn.microsoft.com/azure/app-service/configure-ssl-bindings#enforce-https)
- [Azure Policy built-in definitions for Azure App Service](https://learn.microsoft.com/azure/app-service/policy-reference)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.web/sites)
