---
severity: Important
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Virtual Machine
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.VM.MaintenanceConfig/
---

# Associate a maintenance configuration

## SYNOPSIS

Use a maintenance configuration for virtual machines.

## DESCRIPTION

Virtual machines can be attached to a maintenance configuration which allows customer managed assessments and updates for machine patches within the guest operating system.

## RECOMMENDATION

Consider automatically managing and applying operating system updates by associating a maintenance configuration.

## EXAMPLES

### Configure with Azure template

To deploy virtual machines that pass this rule:

- Deploy a `Microsoft.Maintenance/configurationAssignments` sub-resource (extension resource).
- Set the `properties.maintenanceConfigurationId` property to the linked maintenance configuration resource Id.

For example:

```json
{
  "type": "Microsoft.Maintenance/configurationAssignments",
  "apiVersion": "2022-11-01-preview",
  "name": "[parameters('assignmentName')]",
  "location": "[parameters('location')]",
  "scope": "[format('Microsoft.Compute/virtualMachines/{0}', parameters('name'))]",
  "properties": {
    "maintenanceConfigurationId": "[parameters('maintenanceConfigurationId')]"
  },
  "dependsOn": [
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
resource config 'Microsoft.Maintenance/configurationAssignments@2022-11-01-preview' = {
  name: assignmentName
  location: location
  scope: vm
  properties: {
    maintenanceConfigurationId: maintenanceConfigurationId
  }
}
```

## NOTES

Operating system updates with Update Managment center is a preview feature.
Not all operating systems are supported, check out the `LINKS` section for more information.
Update management center doesn't support driver updates.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/well-architected/devops/automation-infrastructure)
- [About Update management center](https://learn.microsoft.com/azure/update-center/overview)
- [How to programmatically manage updates for Azure VMs](https://learn.microsoft.com/azure/update-center/manage-vms-programmatically)
- [Manage Update configuration settings](https://learn.microsoft.com/azure/update-center/manage-update-settings)
- [Supported operating systems](https://learn.microsoft.com/azure/update-center/support-matrix?tabs=azurevm%2Cazurevm-os#supported-operating-systems)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.maintenance/configurationassignments)
