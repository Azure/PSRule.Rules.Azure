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

- For App Service apps on Linux-based plans:
  - Set the `properties.siteConfig.linuxFxVersion` property to `NODE|20-lts`.
  - It is also possible to set this for sub-resources by:
    - If the type is `Microsoft.Web/sites/slots`, set the `properties.siteConfig.linuxFxVersion` property to `NODE|20-lts`.
    - If the type is `Microsoft.Web/sites/config` and the `name` property is set to `web`, set the `properties.linuxFxVersion` property to `NODE|20-lts`.
    - If the type is `Microsoft.Web/sites/slots/config` and the `name` property is set to `web`, set the `properties.linuxFxVersion` property to `NODE|20-lts`.
- For App Service apps on Windows-based plans:
  - Set the `properties.siteConfig.appSettings.WEBSITE_NODE_DEFAULT_VERSION` property to `~20`.
  - It is also possible to set this for sub-resources by:
    - If the type is `Microsoft.Web/sites/slots`, set the `properties.siteConfig.appSettings.WEBSITE_NODE_DEFAULT_VERSION` property to `~20`.
    - If the type is `Microsoft.Web/sites/config` and the `name` property is set to `appsettings`, set the `properties.WEBSITE_NODE_DEFAULT_VERSION` property to `~20`.
    - If the type is `Microsoft.Web/sites/slots/config` and the `name` property is set to `appsettings`, set the `properties.WEBSITE_NODE_DEFAULT_VERSION` property to `~20`.
    - If the type is `Microsoft.Web/sites/config` and the `name` property is set to `web`, set the `properties.appSettings.WEBSITE_NODE_DEFAULT_VERSION` property to `~20`.
    - If the type is `Microsoft.Web/sites/slots/config` and the `name` property is set to `web`, set the `properties.appSettings.WEBSITE_NODE_DEFAULT_VERSION` property to `~20`.

For example for Linux:

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

For example for Windows:

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
      "linuxFxVersion": "~20"
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.Web/serverfarms', parameters('planName'))]"
  ]
}
```

### Configure with Bicep

To deploy App Services that pass this rule:

- For App Service apps on Linux-based plans:
  - Set the `properties.siteConfig.linuxFxVersion` property to `NODE|20-lts`.
  - It is also possible to set this for sub-resources by:
    - If the type is `Microsoft.Web/sites/slots`, set the `properties.siteConfig.linuxFxVersion` property to `NODE|20-lts`.
    - If the type is `Microsoft.Web/sites/config` and the `name` property is set to `web`, set the `properties.linuxFxVersion` property to `NODE|20-lts`.
    - If the type is `Microsoft.Web/sites/slots/config` and the `name` property is set to `web`, set the `properties.linuxFxVersion` property to `NODE|20-lts`.
- For App Service apps on Windows-based plans:
  - Set the `properties.siteConfig.appSettings.WEBSITE_NODE_DEFAULT_VERSION` property to `~20`.
  - It is also possible to set this for sub-resources by:
    - If the type is `Microsoft.Web/sites/slots`, set the `properties.siteConfig.appSettings.WEBSITE_NODE_DEFAULT_VERSION` property to `~20`.
    - If the type is `Microsoft.Web/sites/config` and the `name` property is set to `appsettings`, set the `properties.WEBSITE_NODE_DEFAULT_VERSION` property to `~20`.
    - If the type is `Microsoft.Web/sites/slots/config` and the `name` property is set to `appsettings`, set the `properties.WEBSITE_NODE_DEFAULT_VERSION` property to `~20`.
    - If the type is `Microsoft.Web/sites/config` and the `name` property is set to `web`, set the `properties.appSettings.WEBSITE_NODE_DEFAULT_VERSION` property to `~20`.
    - If the type is `Microsoft.Web/sites/slots/config` and the `name` property is set to `web`, set the `properties.appSettings.WEBSITE_NODE_DEFAULT_VERSION` property to `~20`.

For example for Linux:

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

For example for Windows:

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
      linuxFxVersion: '~20'
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
