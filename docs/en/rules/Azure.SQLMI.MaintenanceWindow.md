---
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: SQL Managed Instance
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQLMI.MaintenanceWindow/
---

# Customer-controlled maintenance window configuration

## SYNOPSIS

Configure a customer-controlled maintenance window for Azure SQL Managed Instances.

## DESCRIPTION

Azure SQL Managed Instances undergo periodic maintenance to ensure your managed databases remains secure, stable, and up-to-date.
This maintenance includes applying security updates, system upgrades, and software patches.

Maintenance windows can be scheduled in two ways for each instance:

- System-Managed Schedule: The system automatically selects a 9-hour maintenance window between 8:00 AM to 5:00 PM local time, Monday - Sunday.
  - Urgent updates may occur outside of it. To ensure all updates occur only during the maintenance window, select a non-default option.
- Custom Schedule: You can specify a preferred 8-hour maintenance window by choosing between two non-default maintenance windows:
  - Weekday window: 10:00 PM to 6:00 AM local time, Monday - Thursday.
  - Weekend window: 10:00 PM to 6:00 AM local time, Friday - Sunday.

By configuring a customer-controlled maintenance window, you can schedule updates to occur during a preferred time, ideally outside business hours, minimizing disruptions.

There are limitations to the non-default maintenance windows. You can find more details about this in the documentation.

## RECOMMENDATION

Consider using a customer-controlled maintenance window to efficiently schedule updates and minimize disruptions.

## EXAMPLES

### Configure with Azure template

To configure managed instances that pass this rule:

- Set the `properties.maintenanceConfigurationId` property to `/subscriptions/<subscriptionId>/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_<RegionPlaceholder>_MI_1` or `SQL_<RegionPlaceholder>_MI_2`.

For example:

```json
{
  "type": "Microsoft.Sql/managedInstances",
  "apiVersion": "2023-05-01-preview",
  "name": "[parameters('sqlManagedInstanceName'))]",
  "location": "westeurope",
  "sku": {
    "name": "GP_Gen5",
  },
  "properties": {
    "maintenanceConfigurationId": "[subscriptionResourceId('Microsoft.Maintenance/publicMaintenanceConfigurations', 'SQL_WestEurope_MI_1')]"
  }
}
```

### Configure with Bicep

To configure managed instances that pass this rule:

- Set the `properties.maintenanceConfigurationId` property to `/subscriptions/<subscriptionId>/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_<RegionPlaceholder>_MI_1` or `SQL_<RegionPlaceholder>_MI_2`.

For example:

```bicep
resource maintenanceWindow 'Microsoft.Maintenance/publicMaintenanceConfigurations@2023-04-01' existing = {
  scope: subscription()
  name: 'SQL_WestEurope_MI_1'
}

resource sqlManagedInstance 'Microsoft.Sql/managedInstances@2023-05-01-preview' = {
  name: sqlManagedInstanceName
  location: 'westeurope'
  sku: {
    name: 'GP_Gen5'
  }
  properties: {
    maintenanceConfigurationId: maintenanceWindow.id
  }
}
```

## NOTES

For managed instances within an instance pool, the maintenance configuration set at the instance pool level is inherited by all instances within that pool.
However, instance pools do not support customer-controlled maintenance windows directly.
To specify maintenance windows, you must configure them at the individual instance level, thereby overriding the inherited instance pool configuration.

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Maintenance window in Azure SQL Managed Instance](https://learn.microsoft.com/azure/azure-sql/managed-instance/maintenance-window)
- [Configure maintenance window](https://learn.microsoft.com/azure/azure-sql/managed-instance/maintenance-window-configure)
- [Azure deployment reference - Maintenance Configuration](https://learn.microsoft.com/azure/templates/microsoft.maintenance/publicmaintenanceconfigurations)
- [Azure deployment reference - Azure SQL Managed Instance](https://learn.microsoft.com/azure/templates/microsoft.sql/managedinstances)
