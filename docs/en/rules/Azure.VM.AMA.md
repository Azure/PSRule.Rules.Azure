---
severity: Important
pillar: Operational Excellence
category: Monitoring
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.AMA/
---

# Use Azure Monitor Agent

## SYNOPSIS

Use Azure Monitor Agent for collecting monitoring data.

## DESCRIPTION

Azure Monitor Agent (AMA) collects monitoring data from the guest operating system of virtual machines.
Data collected gets delivered to Azure Monitor for use by features, insights and other services, such as Microsoft Defender for Cloud.

Azure Monitor Agent replaces all of Azure Monitor's legacy monitoring agents.

## RECOMMENDATION

Virtual Machines should install Azure Monitor Agent.

## EXAMPLES

### Configure with Azure template

To deploy virtual machines that pass this rule:

- Deploy a extension sub-resource `Microsoft.Compute/virtualMachines/extensions`.
- Set `properties.publisher` to `Microsoft.Azure.Monitor`.
- Set `properties.type` to `AzureMonitorWindowsAgent` (Windows) or `AzureMonitorLinuxAgent` (Linux).

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

- Deploy a extension sub-resource `Microsoft.Compute/virtualMachines/extensions`.
- Set `properties.publisher` to `Microsoft.Azure.Monitor`.
- Set `properties.type` to `AzureMonitorWindowsAgent` (Windows) or `AzureMonitorLinuxAgent` (Linux).

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

## NOTES

The Azure Monitor Agent (AMA) itself does not include all configuration needed, additionally data collection rules and associations are required.

## LINKS

- [Monitoring](https://learn.microsoft.com/azure/architecture/framework/devops/checklist)
- [Azure Monitor Agent overview](https://learn.microsoft.com/azure/azure-monitor/agents/agents-overview)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines/extensions)
