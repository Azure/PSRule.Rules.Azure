---
reviewed: 2025-03-07
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: App Service
resourceType: Microsoft.Web/sites,Microsoft.Web/sites/slots
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.MinTLS/
ms-content-id: e19fbe7e-da05-47d4-8de1-2fdf52ada662
---

# App Service site allows insecure TLS versions

## SYNOPSIS

App Service should not accept weak or deprecated transport protocols for client-server communication.

## DESCRIPTION

The minimum version of TLS that Azure App Service accepts is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

App Service lets you disable outdated protocols and enforce TLS 1.2.
By default, a minimum of TLS 1.2 is enforced.

## RECOMMENDATION

Consider configuring the minimum supported TLS version to be 1.2.
Also consider using Azure Policy to audit or enforce this configuration.

## EXAMPLES

### Configure with Bicep

To deploy App Services that pass this rule:

- Set the `properties.siteConfig.minTlsVersion` property to `1.2` or `1.3`.

For example:

```bicep
resource web 'Microsoft.Web/sites@2024-04-01' = {
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

<!-- external:avm avm/res/web/site siteConfig.minTlsVersion -->

### Configure with Azure template

To deploy App Services that pass this rule:

- Set the `properties.siteConfig.minTlsVersion` property to `1.2` or `1.3`.

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

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [App Service apps should use the latest TLS version](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/App%20Service/RequireLatestTls_WebApp_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/f0e6e85b-9b9f-4a4b-b67b-f730d42f1b0b`.
- [App Service app slots should use the latest TLS version](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/App%20Service/RequireLatestTls_WebApp_Slot_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/4ee5b817-627a-435a-8932-116193268172`.
- [Configure App Service apps to use the latest TLS version](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/App%20Service/RequireLatestTls_WebApp_DINE.json)
  `/providers/Microsoft.Authorization/policyDefinitions/ae44c1d1-0df2-4ca9-98fa-a3d3ae5b409d`.
- [Configure App Service app slots to use the latest TLS version](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/App%20Service/RequireLatestTls_WebApp_Slot_DINE.json)
  `/providers/Microsoft.Authorization/policyDefinitions/014664e7-e348-41a3-aeb9-566e4ff6a9df`.

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#data-in-transit)
- [DP-3: Encrypt sensitive data in transit](https://learn.microsoft.com/security/benchmark/azure/baselines/app-service-security-baseline#dp-3-encrypt-sensitive-data-in-transit)
- [Enforce TLS versions](https://learn.microsoft.com/azure/app-service/configure-ssl-bindings#enforce-tls-versions)
- [TLS encryption in Azure](https://learn.microsoft.com/azure/security/fundamentals/encryption-overview#tls-encryption-in-azure)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Insecure protocols](https://learn.microsoft.com/Azure/app-service/overview-security#insecure-protocols-http-tls-10-ftp)
- [Azure Policy built-in definitions for Azure App Service](https://learn.microsoft.com/azure/app-service/policy-reference)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.web/sites)
