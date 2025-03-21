---
reviewed: 2024-06-12
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Virtual Machine
resourceType: Microsoft.Compute/virtualMachines,Microsoft.Maintenance/configurationAssignments
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.MaintenanceConfig/
---

# Associate a maintenance configuration

## SYNOPSIS

Use a maintenance configuration for virtual machines.

## DESCRIPTION

Azure Virtual Machines (VMs) support maintenance configurations.
You can use the Maintenance Configurations to control and manage updates for Azure VM resources.
Configuring a maintenance window and time zone allows you to reduce disruptions to your workloads during peak hours.

If a maintenance configuration is not associated:

- Updates managed by the platform may be still be scheduled for your virtual machine.
- The schedule determined by the platform may not align with your maintenance window.

Maintenance configurations also integrate with Azure Update Manager.
Azure Update Manager can be used to apply guest operating system (OS) updates to keep your VMs secure and compliant.

## RECOMMENDATION

Consider associating a maintenance configuration to your VM to reduce unplanned disruptions to your workloads.

## EXAMPLES

### Configure with Azure template

To deploy virtual machines that pass this rule:

- Deploy a `Microsoft.Maintenance/configurationAssignments` sub-resource (extension resource).
- Set the `properties.maintenanceConfigurationId` property to the linked maintenance configuration resource Id.

For example:

```json
{
  "type": "Microsoft.Maintenance/configurationAssignments",
  "apiVersion": "2023-04-01",
  "scope": "[format('Microsoft.Compute/virtualMachines/{0}', parameters('name'))]",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "maintenanceConfigurationId": "[resourceId('Microsoft.Maintenance/maintenanceConfigurations', parameters('name'))]"
  },
  "dependsOn": [
    "[resourceId('Microsoft.Maintenance/maintenanceConfigurations', parameters('name'))]",
    "[resourceId('Microsoft.Compute/virtualMachines', parameters('name'))]"
  ]
}
```

### Configure with Bicep

To deploy virtual machines that pass this rule:

- Deploy a `Microsoft.Maintenance/configurationAssignments` sub-resource (extension resource).
- Set the `properties.maintenanceConfigurationId` property to the linked maintenance configuration resource Id.

For example:

```bicep
resource config 'Microsoft.Maintenance/configurationAssignments@2023-04-01' = {
  name: name
  location: location
  scope: vm
  properties: {
    maintenanceConfigurationId: maintenanceConfiguration.id
  }
}
```

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Managing VM updates with Maintenance Configurations](https://learn.microsoft.com/azure/virtual-machines/maintenance-configurations)
- [About Azure Update Manager](https://learn.microsoft.com/azure/update-manager/overview)
- [Manage update configuration settings](https://learn.microsoft.com/azure/update-manager/manage-update-settings)
- [Support matrix for Azure Update Manager](https://learn.microsoft.com/azure/update-manager/support-matrix)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.maintenance/configurationassignments)
