---
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Azure Database
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.MaintenanceWindow/
---

# Customer-controlled maintenance window configuration

## SYNOPSIS

Configure a customer-controlled maintenance window for Azure SQL databases.

## DESCRIPTION

Azure SQL databases undergo periodic maintenance to ensure your managed database remains secure, stable, and up-to-date. This maintenance includes applying security updates, system upgrades, and software patches.

Maintenance windows can be scheduled in two ways for each database:

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

To configure databases that pass this rule:

- Set the `properties.maintenanceConfigurationId` property to `/subscriptions/<subscriptionId>/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_<RegionPlaceholder>_DB_1` or `SQL_<RegionPlaceholder>_DB_2`.

For example:

```json
{
  "type": "Microsoft.Sql/servers/databases",
  "apiVersion": "2023-05-01-preview",
  "name": "[format('{0}/{1}', parameters('serverName'), parameters('sqlDbName'))]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "P1",
    "tier": "Premium"
  },
  "properties": {
    "maintenanceConfigurationId": "[subscriptionResourceId('Microsoft.Maintenance/publicMaintenanceConfigurations', 'SQL_WestEurope_DB_1')]"
  },
  "dependsOn": [
    "[resourceId('Microsoft.Sql/servers', parameters('serverName'))]"
  ]
}
```

### Configure with Bicep

To configure databases that pass this rule:

- Set the `properties.maintenanceConfigurationId` property to `/subscriptions/<subscriptionId>/providers/Microsoft.Maintenance/publicMaintenanceConfigurations/SQL_<RegionPlaceholder>_DB_1` or `SQL_<RegionPlaceholder>_DB_2`.

For example:

```bicep
resource maintenanceWindow 'Microsoft.Maintenance/publicMaintenanceConfigurations@2023-04-01' existing = {
  scope: subscription()
  name: 'SQL_WestEurope_DB_1'
}

resource sqlDb 'Microsoft.Sql/servers/databases@2023-05-01-preview' = {
  parent: sqlServer
  name: sqlDbName
  location: 'westeurope'
  sku: {
    name: 'P1'
    tier: 'Premium'
  }
  properties: {
    maintenanceConfigurationId: maintenanceWindow.id
  }
}
``` 

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Maintenance window in Azure SQL Database](https://learn.microsoft.com/azure/azure-sql/database/maintenance-window)
- [Configure maintenance window](https://learn.microsoft.com/azure/azure-sql/database/maintenance-window-configure)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.maintenance/publicmaintenanceconfigurations)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbformysql/flexibleservers)
