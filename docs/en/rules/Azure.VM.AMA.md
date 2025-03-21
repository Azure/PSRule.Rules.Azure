---
reviewed: 2024-01-05
severity: Important
pillar: Operational Excellence
category: OE:07 Monitoring system
resource: Virtual Machine
resourceType: Microsoft.Compute/virtualMachines,Microsoft.Compute/virtualMachines/extensions
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.AMA/
---

# Use Azure Monitor Agent

## SYNOPSIS

Use Azure Monitor Agent for collecting monitoring data from VMs.

## DESCRIPTION

Azure Monitor is the platform capability for monitoring and observability in Azure.
Azure Monitor collects monitoring telemetry from a variety of on-premises, multi-cloud, and Azure sources.

To monitor Windows and Linux operating systems the Azure Monitor Agent (AMA) is deployed.
Once the AMA the agent is deployed, collected data gets delivered to Azure Monitor, where is can be used for:

- Monitoring visualizations.
- Triggering alerts.
- Analysis using workbooks and queries.
- Integration with other Azure services.
- Integration with third-party services.

For Azure virtual machines (VMs), virtual machine scale sets (VMSS),
and Azure Arc enabled servers the monitoring agent is deployed as an extension.
The extension also supports modern management capabilities such as Azure Policy,
automatic updates, and deployment as Infrastructure as Code.

The AMA replaces Azure Monitor's legacy monitoring agents.

## RECOMMENDATION

Consider monitoring virtual machines (VMs) with the Azure Monitor Agent.

## EXAMPLES

### Configure with Azure template

To deploy virtual machines that pass this rule:

- Deploy a extension sub-resource `Microsoft.Compute/virtualMachines/extensions`.
  - Set `properties.publisher` to `Microsoft.Azure.Monitor`.
  - Set `properties.type` to `AzureMonitorWindowsAgent` (Windows) or `AzureMonitorLinuxAgent` (Linux).

For example:

```json
{
  "type": "Microsoft.Compute/virtualMachines/extensions",
  "apiVersion": "2023-09-01",
  "name": "[format('{0}/{1}', parameters('name'), 'AzureMonitorWindowsAgent')]",
  "location": "[parameters('location')]",
  "properties": {
    "publisher": "Microsoft.Azure.Monitor",
    "type": "AzureMonitorWindowsAgent",
    "typeHandlerVersion": "1.0",
    "autoUpgradeMinorVersion": true,
    "enableAutomaticUpgrade": true,
    "settings": {
      "authentication": {
        "managedIdentity": {
          "identifier-name": "mi_res_id",
          "identifier-value": "[parameters('amaIdentityId')]"
        }
      }
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.Compute/virtualMachines', parameters('name'))]"
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
resource windowsAgent 'Microsoft.Compute/virtualMachines/extensions@2023-09-01' = {
  parent: vm
  name: 'AzureMonitorWindowsAgent'
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
          'identifier-name': 'mi_res_id'
          'identifier-value': amaIdentityId
        }
      }
    }
  }
}
```

### Configure with Azure CLI

To configure virtual machine using a user-assigned identity:

- Deploy a extension sub-resource `Microsoft.Compute/virtualMachines/extensions`.
  - Set the `--name` parameter to `AzureMonitorWindowsAgent` (Windows) or `AzureMonitorLinuxAgent` (Linux).
  - Fill in the remaining parameters.
    For more information see [Azure Monitor Agent overview](https://learn.microsoft.com/azure/azure-monitor/agents/agents-overview).

For example:

```bash
az vm extension set --name 'AzureMonitorWindowsAgent' --publisher Microsoft.Azure.Monitor --ids '<vm-resource-id>' --enable-auto-upgrade true --settings '{"authentication":{"managedIdentity":{"identifier-name":"mi_res_id","identifier-value":"/subscriptions/<my-subscription-id>/resourceGroups/<my-resource-group>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<my-user-assigned-identity>"}}}'
```

### Configure with Azure PowerShell

To configure virtual machine using a user-assigned identity:

- Deploy a extension sub-resource `Microsoft.Compute/virtualMachines/extensions`.
  - Set the `-ExtensionType` parameter to `AzureMonitorWindowsAgent` (Windows) or `AzureMonitorLinuxAgent` (Linux).
  - Fill in the remaining parameters.
    For more information see [Azure Monitor Agent overview](https://learn.microsoft.com/azure/azure-monitor/agents/agents-overview).

For example:

```powershell
Set-AzVMExtension -Name AzureMonitorWindowsAgent -ExtensionType 'AzureMonitorWindowsAgent' -Publisher Microsoft.Azure.Monitor -ResourceGroupName '<resource-group-name>' -VMName '<virtual-machine-name>' -Location '<location>' -TypeHandlerVersion '1.0' -EnableAutomaticUpgrade $true -SettingString '{"authentication":{"managedIdentity":{"identifier-name":"mi_res_id","identifier-value":"/subscriptions/<my-subscription-id>/resourceGroups/<my-resource-group>/providers/Microsoft.ManagedIdentity/userAssignedIdentities/<my-user-assigned-identity>"}}}'
```

## NOTES

Deploying Azure Monitor Agent (AMA) extension alone does not include all configuration needed.
Additionally data collection rules and associations are required to specify what data is collected and where it is sent.

## LINKS

- [OE:07 Monitoring system](https://learn.microsoft.com/azure/well-architected/operational-excellence/observability)
- [Azure Monitor Agent overview](https://learn.microsoft.com/azure/azure-monitor/agents/agents-overview)
- [Manage Azure Monitor Agent](https://learn.microsoft.com/azure/azure-monitor/agents/azure-monitor-agent-manage)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.compute/virtualmachines/extensions)
