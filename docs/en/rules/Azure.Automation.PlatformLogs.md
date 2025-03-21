---
severity: Important
pillar: Operational Excellence
category: Monitoring
resource: Automation Account
resourceType: Microsoft.Automation/automationAccounts,Microsoft.Insights/diagnosticSettings
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Automation.PlatformLogs/
---

# Automation accounts should collect platform diagnostic logs

## SYNOPSIS

Ensure automation account platform diagnostic logs are enabled.

## DESCRIPTION

To capture platform logs from Automation Accounts, the following diagnostic log categories should be enabled:

- JobLogs
- JobStreams
- DSCNodeStatus

We can also enable all the above with the `allLogs` category group.

To capture metric log categories, th following must be enabled as well:

- AllMetrics - Total Jobs, Total Update Deployment Machine Runs, Total Update Deployment Runs

## RECOMMENDATION

Consider configuring diagnostic settings to capture platform logs from Automation accounts.

## NOTES

Configure `AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST` to enable selective log categories. By default all log categories are selected, as shown below.

```yaml
# YAML: The default AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST configuration option
configuration:
  AZURE_AUTOMATIONACCOUNT_ENABLED_PLATFORM_LOG_CATEGORIES_LIST: ['JobLogs', 'JobStreams', 'DscNodeStatus', 'AllMetrics']
```

## EXAMPLES

### Configure with Azure template

To deploy Automation accounts that pass this rule:

- Deploy a diagnostic settings sub-resource.
- Enable logging for the `JobLogs`, `JobStreams`, `DSCNodeStatus` and `AllMetrics` categories.

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
                        "category": "JobLogs",
                        "enabled": true,
                        "retentionPolicy": {
                            "days": 0,
                            "enabled": false
                        }
                    },
                    {
                        "category": "JobStreams",
                        "enabled": true,
                        "retentionPolicy": {
                            "days": 0,
                            "enabled": false
                        }
                    },
                    {
                        "category": "DSCNodeStatus",
                        "enabled": true,
                        "retentionPolicy": {
                            "days": 0,
                            "enabled": false
                        }
                    }
                ],
                "metrics": [
                  {
                        "category": "AllMetrics",
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

- Deploy a diagnostic settings sub-resource.
- Enable logging for the `JobLogs`, `JobStreams`, `DSCNodeStatus` and `AllMetrics` categories.

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
        category: 'JobLogs'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      },
      {
        category: 'JobStreams'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      },
      {
        category: 'DSCNodeStatus'
        enabled: true
        retentionPolicy: {
          days: 0
          enabled: false
        }
      }
    ]
    metrics: [
      {
        category: 'AllMetrics'
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

- [Platform Monitoring](https://learn.microsoft.com/azure/architecture/framework/devops/monitoring#platform-monitoring)
- [Forward Azure Automation job data to Azure Monitor logs](https://learn.microsoft.com/azure/automation/automation-manage-send-joblogs-log-analytics)
- [Template Reference](https://learn.microsoft.com/azure/templates/microsoft.insights/diagnosticsettings?tabs=bicep)
