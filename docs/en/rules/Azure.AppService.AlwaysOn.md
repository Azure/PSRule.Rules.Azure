---
reviewed: 2023-04-15
severity: Important
pillar: Reliability
category: Application design
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.AlwaysOn/
---

# Use App Service Always On

## SYNOPSIS

Configure Always On for App Service apps.

## DESCRIPTION

Azure App Service apps are automatically unloaded when there's no traffic.
Unloading apps reduces resource consumption when apps share a single App Services Plan.
After an app have been unloaded, the next web request will trigger a cold start of the app.
A cold start of the app can cause request timeouts.

Web apps using continuous WebJobs or WebJobs triggered with a CRON expression must use always on to start.

## RECOMMENDATION

Consider enabling Always On for each App Services app.

## EXAMPLES

### Configure with Azure template

To deploy App Services that pass this rule:

- Set the `properties.siteConfig.alwaysOn` property to `true`.

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

- Set the `properties.siteConfig.alwaysOn` property to `true`.

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

## NOTES

The Always On feature of App Service is not applicable to Azure Functions and Standard Logic Apps under most circumstances.
To reduce false positives, this rule ignores apps based on Azure Functions and Standard Logic Apps.

When running in a Consumption Plan or Premium Plan you should not enable Always On.
On a Consumption plan the platform activates function apps automatically.
On a Premium plan the platform keeps your desired number of pre-warmed instances always on automatically.

## LINKS

- [Service guide](https://learn.microsoft.com/azure/well-architected/service-guides/app-service-web-apps)
- [Configure an App Service app](https://learn.microsoft.com/azure/app-service/configure-common#configure-general-settings)
- [The Ultimate Guide to Running Healthy Apps in the Cloud](https://azure.github.io/AppService/2020/05/15/Robust-Apps-for-the-cloud.html#update-your-default-settings)
- [Always on with Azure Functions](https://github.com/Azure/Azure-Functions/wiki/Enable-Always-On-when-running-on-dedicated-App-Service-Plan)
- [Dedicated hosting plans for Azure Functions](https://learn.microsoft.com/azure/azure-functions/dedicated-plan)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.web/sites)
