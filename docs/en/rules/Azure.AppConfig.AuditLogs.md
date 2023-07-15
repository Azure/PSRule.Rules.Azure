---
reviewed: 2023-07-15
severity: Important
pillar: Security
category: Monitor
resource: App Configuration
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppConfig.AuditLogs/
---

# Audit App Configuration Store

## SYNOPSIS

Ensure app configuration store audit diagnostic logs are enabled.

## DESCRIPTION

To capture logs that record interactions with data or the settings of the app configuration store, diagnostic settings must be configured.

When configuring diagnostic settings, enable one of the following:

- `Audit` category.
- `audit` category group.
- `allLogs` category group.

Management operations for App Configuration Store are captured automatically within Azure Activity Logs.

## RECOMMENDATION

Consider configuring diagnostic settings to record interactions with data or the settings of the App Configuration Store.

## EXAMPLES

### Configure with Azure template

To deploy an App Configuration Store that pass this rule:

- Deploy a diagnostic settings sub-resource (extension resource).
- Enable `Audit` category or `audit` category group or `allLogs` category group.

For example:

```json
{
    "parameters": {
    "name": {
      "type": "string",
      "metadata": {
        "description": "The name of the App Configuration Store."
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "The location resources will be deployed."
      }
    },
    "workspaceId": {
      "type": "string",
      "metadata": {
        "description": "The resource id of the Log Analytics workspace to send diagnostic logs to."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.AppConfiguration/configurationStores",
      "apiVersion": "2022-05-01",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "standard"
      },
      "properties": {
        "disableLocalAuth": true,
        "enablePurgeProtection": true
      }
    },
    {
      "type": "Microsoft.Insights/diagnosticSettings",
      "apiVersion": "2021-05-01-preview",
      "scope": "[format('Microsoft.AppConfiguration/configurationStores/{0}', parameters('name'))]",
      "name": "[format('{0}-diagnostic', parameters('name'))]",
      "properties": {
        "logs": [
          {
            "categoryGroup": "audit",
            "enabled": true,
            "retentionPolicy": {
              "days": 90,
              "enabled": true
            }
          }
        ],
        "workspaceId": "[parameters('workspaceId')]"
      },
      "dependsOn": [
        "[resourceId('Microsoft.AppConfiguration/configurationStores', parameters('name'))]"
      ]
    }
  ]
}
```

### Configure with Bicep

To deploy an App Configuration Store that pass this rule:

- Deploy a diagnostic settings sub-resource (extension resource).
- Enable `Audit` category or `audit` category group or `allLogs` category group.

For example:

```bicep
resource store 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: name
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    disableLocalAuth: true
    enablePurgeProtection: true
    publicNetworkAccess: 'Disabled'
  }
}

resource diagnostic 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  scope: store
  name: '${name}-diagnostic'
  properties: {
    logs: [
      {
        categoryGroup: 'audit'
        enabled: true
        retentionPolicy: {
          days: 90
          enabled: true
        }
      }
    ]
    workspaceId: workspaceId
  }
}
```

### Configure with Bicep Public Registry

To deploy an App Configuration Store that pass this rule:

- Configure the `diagnosticSettingsProperties.logs` parameter.
- Enable `Audit` category or `audit` category group or `allLogs` category group.

For example:

```bicep
module store 'br/public:app/app-configuration:1.1.1' = {
  name: 'store'
  params: {
    skuName: 'Standard'
    disableLocalAuth: true
    enablePurgeProtection: true
    publicNetworkAccess: 'Disabled'
    diagnosticSettingsProperties: {
      diagnosticReceivers: {
        workspaceId: workspaceId
      }
      logs: [
        {
          categoryGroup: 'audit'
          enabled: true
          retentionPolicy: {
            days: 90
            enabled: true
          }
        }
      ]
    }
  }
}
```

## LINKS

- [Security audits](https://learn.microsoft.com/azure/architecture/framework/security/monitor-audit)
- [Public registry](https://azure.github.io/bicep-registry-modules/#app)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsetting)
