---
severity: Important
pillar: Operational Excellence
category: Monitoring
resource: Virtual Machine
resourceType: Microsoft.Compute/virtualMachines,Microsoft.Compute/virtualMachines/extensions
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.MigrateAMA/
---

# Migrate to Azure Monitor Agent

## SYNOPSIS

Use Azure Monitor Agent as replacement for Log Analytics Agent.

## DESCRIPTION

The legacy Log Analytics agent will be retired on August 31, 2024. Before that date, you'll need to start using the Azure Monitor agent to monitor your VMs and servers in Azure. The Azure Monitor agent provdes the following benefits over legacy agents:

- Security and performance
  - Enhanced security through Managed Identity and Azure Active Directory (Azure AD) tokens (for clients).
  - A higher events-per-second (EPS) upload rate.
- Cost savings by using data collection rules. Using DCRs is one of the most useful advantages of using Azure Monitor Agent:
  - DCRs let you configure data collection for specific machines connected to a workspace as compared to the "all or nothing" approach of legacy agents.
  - With DCRs, you can define which data to ingest and which data to filter out to reduce workspace clutter and save on costs.
- Simpler management of data collection, including ease of troubleshooting:
  - Easy multihoming on Windows and Linux.
  - Centralized, "in the cloud" agent configuration makes every action simpler and more easily scalable throughout the data collection lifecycle, from onboarding to deployment to updates and changes over time.
  - Greater transparency and control of more capabilities and services, such as Microsoft Sentinel, Defender for Cloud, and VM Insights.
- A single agent that consolidates all features necessary to address all telemetry data collection needs across servers and client devices running Windows 10 or 11. A single agent is the goal, although Azure Monitor Agent currently converges with the Log Analytics agents.

## RECOMMENDATION

Virtual Machines should migrate to Azure Monitor Agent.

## EXAMPLES

### Configure with Azure template

To deploy virtual machines that pass this rule:

- Deploy a extension sub-resource (extension resource).
- Set `properties.publisher` to `'Microsoft.Azure.Monitor'`.
- Set `properties.type` to `'AzureMonitorWindowsAgent'` (Windows) or `'AzureMonitorLinuxAgent'` (Linux).

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "vmName": {
      "type": "string"
    },
    "location": {
      "type": "string"
    },
    "userAssignedManagedIdentity": {
      "type": "string"
    }
  },
  "resources": [
    {
      "type": "Microsoft.Compute/virtualMachines/extensions",
      "apiVersion": "2022-08-01",
      "name": "[format('{0}/AzureMonitorWindowsAgent', parameters('vmName'))]",
      "location": "[parameters('location')]",
      "properties": {
        "publisher": "Microsoft.Azure.Monitor",
        "type": "AzureMonitorWindowsAgent",
        "typeHandlerVersion": "1.0",
        "settings": {
          "authentication": {
            "managedIdentity": {
              "identifier-name": "mi_res_id",
              "identifier-value": "[parameters('userAssignedManagedIdentity')]"
            }
          }
        },
        "autoUpgradeMinorVersion": true,
        "enableAutomaticUpgrade": true
      }
    }
  ]
}
```

### Configure with Bicep

To deploy virtual machines that pass this rule:

- Deploy a extension sub-resource (extension resource).
- Set `properties.publisher` to `'Microsoft.Azure.Monitor'`.
- Set `properties.type` to `'AzureMonitorWindowsAgent'` (Windows) or `'AzureMonitorLinuxAgent'` (Linux).

For example:

```bicep
param vmName string
param location string
param userAssignedManagedIdentity string

resource windowsAgent 'Microsoft.Compute/virtualMachines/extensions@2022-08-01' = {
  name: '${vmName}/AzureMonitorWindowsAgent'
  location: location
  properties: {
    publisher: 'Microsoft.Azure.Monitor'
    type: 'AzureMonitorWindowsAgent'
    typeHandlerVersion: '1.0'
    autoUpgradeMinorVersion: true
    enableAutomaticUpgrade: true
    settings: {
      authentication: {
        managedIdentity: {
          identifier-name: 'mi_res_id'
          identifier-value: userAssignedManagedIdentity
        }
      }
    }
  }
}
```

## LINKS

- [Monitoring](https://learn.microsoft.com/azure/architecture/framework/devops/checklist)
- [Log Analytics agent retiring](https://azure.microsoft.com/updates/were-retiring-the-log-analytics-agent-in-azure-monitor-on-31-august-2024)
- [Migrate to Azure Monitor Agent from Log Analytics Agent](https://learn.microsoft.com/azure/azure-monitor/agents/azure-monitor-agent-migration)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines/extensions)
