---
severity: Important
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Arc
resourceType: Microsoft.HybridCompute/machines,Microsoft.Maintenance/configurationAssignments
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Arc.Server.MaintenanceConfig/
---

# Associate a maintenance configuration

## SYNOPSIS

Use a maintenance configuration for Arc-enabled servers.

## DESCRIPTION

Arc-enabled servers can be attached to a maintenance configuration which allows customer managed assessments and updates for machine patches within the guest operating system.

## RECOMMENDATION

Consider automatically managing and applying operating system updates with a maintenance configuration.

## EXAMPLES

### Configure with Azure template

To deploy Arc-enabled servers that pass this rule:

- Deploy a `Microsoft.Maintenance/configurationAssignments` sub-resource (extension resource).
- Set the `properties.maintenanceConfigurationId` property to the linked maintenance configuration resource Id.

For example:

```json
{
  "type": "Microsoft.Maintenance/configurationAssignments",
  "apiVersion": "2022-11-01-preview",
  "name": "[parameters('assignmentName')]",
  "location": "[parameters('location')]",
  "scope": "[format('Microsoft.HybridCompute/machines/{0}', parameters('name'))]",
  "properties": {
    "maintenanceConfigurationId": "[parameters('maintenanceConfigurationId')]"
  },
  "dependsOn": [
    "[resourceId('Microsoft.HybridCompute/machines', parameters('name'))]"
  ]
}
```

### Configure with Bicep

To deploy Arc-enabled servers that pass this rule:

- Deploy a `Microsoft.Maintenance/configurationAssignments` sub-resource (extension resource).
- Set the `properties.maintenanceConfigurationId` property to the linked maintenance configuration resource Id.

For example:

```bicep
resource config 'Microsoft.Maintenance/configurationAssignments@2022-11-01-preview' = {
  name: assignmentName
  location: location
  scope: arcServer
  properties: {
    maintenanceConfigurationId: maintenanceConfigurationId
  }
}
```

## NOTES

Operating system updates with Update Managment center is a preview feature.
Not all regions or operating systems are supported, check out the `LINKS` section for supported regions.
Update management center doesn't support driver updates.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/well-architected/devops/automation-infrastructure)
- [About Update management center](https://learn.microsoft.com/azure/update-center/overview)
- [How to programmatically manage updates for Azure Arc-enabled servers](https://learn.microsoft.com/azure/update-center/manage-arc-enabled-servers-programmatically)
- [Manage Update configuration settings](https://learn.microsoft.com/azure/update-center/manage-update-settings)
- [Supported regions](https://learn.microsoft.com/azure/update-center/support-matrix?tabs=azurearc%2Cazurearc-os#supported-regions)
- [Supported operating systems](https://learn.microsoft.com/azure/update-center/support-matrix?tabs=azurearc%2Cazurearc-os#supported-operating-systems)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.maintenance/configurationassignments)
