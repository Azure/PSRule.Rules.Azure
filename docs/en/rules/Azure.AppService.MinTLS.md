---
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.MinTLS/
ms-content-id: e19fbe7e-da05-47d4-8de1-2fdf52ada662
---

# App Service minimum TLS version

## SYNOPSIS

App Service should reject TLS versions older than 1.2.

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

- Set the `properties.siteConfig.minTlsVersion` property to `1.2`.

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

- Set the `properties.siteConfig.minTlsVersion` property to `1.2`.

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

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#data-in-transit)
- [DP-3: Encrypt sensitive data in transit](https://learn.microsoft.com/security/benchmark/azure/baselines/app-service-security-baseline#dp-3-encrypt-sensitive-data-in-transit)
- [Enforce TLS versions](https://learn.microsoft.com/azure/app-service/configure-ssl-bindings#enforce-tls-versions)
- [TLS encryption in Azure](https://learn.microsoft.com/azure/security/fundamentals/encryption-overview#tls-encryption-in-azure)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Insecure protocols](https://learn.microsoft.com/Azure/app-service/overview-security#insecure-protocols-http-tls-10-ftp)
- [Azure Policy built-in definitions for Azure App Service](https://learn.microsoft.com/azure/app-service/policy-reference)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.web/sites)
