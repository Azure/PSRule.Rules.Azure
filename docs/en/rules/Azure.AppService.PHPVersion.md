---
reviewed: 2024-03-24
severity: Important
pillar: Security
category: SE:02 Secured development lifecycle
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.PHPVersion/
---

# Use a newer PHP runtime version

## SYNOPSIS

Configure applications to use newer PHP runtime versions.

## DESCRIPTION

Within a App Service app, the version of PHP runtime used to run application/ site code is configurable.

Overtime, a specific version of PHP may become outdated and no longer supported by Microsoft in Azure App Service.
This can lead to security vulnerabilities or are simply not able to use the latest security features.

PHP 8.0 and 8.1 are approaching end of support.

## RECOMMENDATION

Consider updating the site to use a newer PHP runtime version such as `8.2`.

## EXAMPLES

### Configure with Azure template

To deploy App Services that pass this rule:

- Set `properties.siteConfig.linuxFxVersion` to a minimum of `PHP|8.2`.

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
    "clientAffinityEnabled": false,
    "siteConfig": {
      "alwaysOn": true,
      "minTlsVersion": "1.2",
      "ftpsState": "Disabled",
      "http20Enabled": true,
      "healthCheckPath": "/healthz",
      "linuxFxVersion": "PHP|8.2"
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.Web/serverfarms', parameters('planName'))]"
  ]
}
```

### Configure with Bicep

To deploy App Services that pass this rule:

- Set `properties.siteConfig.linuxFxVersion` to a minimum of `PHP|8.2`.

For example:

```bicep
resource php 'Microsoft.Web/sites@2023-01-01' = {
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
      http20Enabled: true
      healthCheckPath: '/healthz'
      linuxFxVersion: 'PHP|8.2'
    }
  }
}
```

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [App Service apps that use PHP should use a specified 'PHP version'](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/App%20Service/Webapp_Audit_PHP_Latest.json)
  `/providers/Microsoft.Authorization/policyDefinitions/7261b898-8a84-4db8-9e04-18527132abb3`
- [App Service app slots that use PHP should use a specified 'PHP version'](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/App%20Service/Webapp_Slot_Audit_PHP_Latest.json)
  `/providers/Microsoft.Authorization/policyDefinitions/f466b2a6-823d-470d-8ea5-b031e72d79ae`

## NOTES

From November 2022 - PHP is only supported on Linux-based plans.

## LINKS

- [SE:02 Secured development lifecycle](https://learn.microsoft.com/azure/well-architected/security/secure-development-lifecycle)
- [Set PHP Version](https://learn.microsoft.com/azure/app-service/configure-language-php?pivots=platform-linux#set-php-version)
- [PHP on App Service](https://github.com/Azure/app-service-linux-docs/blob/master/Runtime_Support/php_support.md)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.web/sites)
