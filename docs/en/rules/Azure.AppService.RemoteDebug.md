---
severity: Important
pillar: Security
category: SE:08 Hardening resources
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

- Set the `properties.siteConfig.remoteDebuggingEnabled` property to `false`.

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

- Set the `properties.siteConfig.remoteDebuggingEnabled` property to `false`.

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

<!-- external:avm avm/res/web/site siteConfig.remoteDebuggingEnabled -->

## LINKS

- [SE:08 Hardening resources](https://learn.microsoft.com/azure/well-architected/security/harden-resources)
- [PV-2: Audit and enforce secure configurations](https://learn.microsoft.com/security/benchmark/azure/baselines/app-service-security-baseline#pv-2-audit-and-enforce-secure-configurations)
- [Configure general settings](https://learn.microsoft.com/azure/app-service/configure-common#configure-general-settings)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.web/sites)
