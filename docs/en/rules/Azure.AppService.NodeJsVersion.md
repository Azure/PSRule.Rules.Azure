---
severity: Important
pillar: Security
category: SE:02 Secured development lifecycle
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.NodeJsVersion/
---

# Use a supported Node.js runtime version

## SYNOPSIS

Configure applications to use supported Node.js runtime versions.

## DESCRIPTION

In an App Service app, you can configure the Node.js runtime version used to run your application or site code.

Extended support for Node.js 18 LTS will end on April 30, 2025. While apps hosted on App Service will continue to operate, security updates and customer support for Node.js 18 LTS will no longer be provided after this date.

To avoid potential security vulnerabilities and minimize risks for your App Service apps, it is recommended to upgrade your apps to Node.js 20 LTS before April 30, 2025.

## RECOMMENDATION

Consider updating applications to use supported Node.js runtime versions to maintain security and support.

## EXAMPLES

### Configure with Azure template

To deploy App Services that pass this rule:

- For Linux-based apps and slots:
  - Set the `properties.siteConfig.linuxFxVersion` property to `NODE|20-lts`.
- For Windows-based apps and slots:
  - Add an app setting within `properties.siteConfig.appSettings` by creating an object with the `name` and `value` properties.
  - Set the `name` property to `WEBSITE_NODE_DEFAULT_VERSION`.
  - Set the `value` property to `~20`.

In addition to setting the `properties.siteConfig` property, you can also use a sub-resource.

For example (Linux app):

```json
{
  "type": "Microsoft.Web/sites",
  "apiVersion": "2022-09-01",
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
      "minTlsVersion": "1.2",
      "linuxFxVersion": "NODE|20-lts"
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.Web/serverfarms', parameters('planName'))]"
  ]
}
```

For example (Windows app):

```json
{
  "type": "Microsoft.Web/sites",
  "apiVersion": "2022-09-01",
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
      "minTlsVersion": "1.2",
      "appSettings": [
        {
          "name": "WEBSITE_NODE_DEFAULT_VERSION",
          "value": "~20"
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

- For Linux-based apps and slots:
  - Set the `properties.siteConfig.linuxFxVersion` property to `NODE|20-lts`.
- For Windows-based apps and slots:
  - Add an app setting within `properties.siteConfig.appSettings` by creating an object with the `name` and `value` properties.
  - Set the `name` property to `WEBSITE_NODE_DEFAULT_VERSION`.
  - Set the `value` property to `~20`.

In addition to setting the `properties.siteConfig` property, you can also use a sub-resource.

For example (Linux app):

```bicep
resource linuxWeb 'Microsoft.Web/sites@2022-09-01' = {
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
      minTlsVersion: '1.2'
      linuxFxVersion: 'NODE|20-lts'
    }
  }
}
```

For example (Windows app):

```bicep
resource windowsWeb 'Microsoft.Web/sites@2022-09-01' = {
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
      minTlsVersion: '1.2'
      appSettings: [
        {
          name: 'WEBSITE_NODE_DEFAULT_VERSION'
          value: '~20'
        }
      ]
    }
  }
}
```

## LINKS

- [SE:02 Secured development lifecycle](https://learn.microsoft.com/azure/well-architected/security/secure-development-lifecycle)
- [Upgrade your App Service apps to Node 20 LTS by 30 April 2025](https://azure.microsoft.com/updates/action-required-upgrade-your-app-service-apps-to-node-20-lts-by-30-april-2025/)
- [Node.js on App Service](https://github.com/Azure/app-service-linux-docs/blob/master/Runtime_Support/node_support.md)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.web/sites)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.web/sites/slots)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.web/sites/config-web)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.web/sites/slots/config-web)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.web/sites/config-appsettings)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.web/sites/slots/config-appsettings)
