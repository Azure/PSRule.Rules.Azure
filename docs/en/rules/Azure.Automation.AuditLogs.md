---
severity: Important
pillar: Security
category: Monitor
resource: Automation Account
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Automation.AuditLogs/
---

# Audit Automation Account data access

## SYNOPSIS

Ensure automation account audit diagnostic logs are enabled.

## DESCRIPTION

To capture logs that record interactions with data or the settings of the automation account, diagnostic settings must be configured.

When configuring diagnostic settings, enabled one of the following:

- `AuditEvent` category.
- `audit` category group.
- `allLogs` category group.

Management operations for Automation Account is captured automatically within Azure Activity Logs.

## RECOMMENDATION

Consider configuring diagnostic settings to record interactions with data or the settings of the Automation Account.

## EXAMPLES

### Configure with Azure template

To deploy Automation accounts that pass this rule:

- Deploy a diagnostic settings sub-resource (extension resource).
- Enable `AuditEvent` category or `audit` category group or `allLogs` category group.

For example:

```json
{
    "parameters": {
        "automationAccountName": {
            "defaultValue": "automation-account1",
            "type": "String"
        },
        "location": {
          "type": "String"
        },
        "workspaceId": {
          "type": "String"
        }
    },
    "variables": {},
    "resources": [
        {
            "type": "Microsoft.Automation/automationAccounts",
            "apiVersion": "2021-06-22",
            "name": "[parameters('automationAccountName')]",
            "location": "[parameters('location')]",
            "identity": {
                "type": "SystemAssigned"
            },
            "properties": {
                "disableLocalAuth": false,
                "sku": {
                    "name": "Basic"
                },
                "encryption": {
                    "keySource": "Microsoft.Automation",
                    "identity": {}
                }
            }
        },
        {
            "comments": "Enable monitoring of Automation Account operations.",
            "type": "Microsoft.Insights/diagnosticSettings",
            "name": "[concat(parameters('automationAccountName'), '/Microsoft.Insights/service')]",
            "apiVersion": "2021-05-01-preview",
            "dependsOn": [
                "[concat('Microsoft.Automation/automationAccounts/', parameters('automationAccountName'))]"
            ],
            "properties": {
                "workspaceId": "[parameters('workspaceId')]",
                "logs": [
                    {
                        "category": "AuditEvent",
                        "enabled": true,
                        "retentionPolicy": {
                            "days": 0,
                            "enabled": false
                        }
                    }
                ]
            }
        }
    ]
}
```

### Configure with Bicep

To deploy Automation accounts that pass this rule:

- Deploy a diagnostic settings sub-resource (extension resource).
- Enable `AuditEvent` category or `audit` category group or `allLogs` category group.

For example:

```bicep
param automationAccountName string = 'automation-account1'
param location string
param workspaceId string

resource automationAccountResource 'Microsoft.Automation/automationAccounts@2021-06-22' = {
  name: automationAccountName
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: false
    sku: {
      name: 'Basic'
    }
    encryption: {
      keySource: 'Microsoft.Automation'
      identity: {}
    }
  }
}

resource automationAccountName_Microsoft_Insights_service 'Microsoft.Insights/diagnosticSettings@2021-05-01-preview' = {
  name: 'diagnosticSettings'
  properties: {
    workspaceId: workspaceId
    logs: [
      {
        category: 'AuditEvent'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
  }
  dependsOn: [
    automationAccountResource
  ]
}
```

## LINKS

- [Security audits](https://learn.microsoft.com/azure/architecture/framework/security/monitor-audit)
- [Template Reference](https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings)
