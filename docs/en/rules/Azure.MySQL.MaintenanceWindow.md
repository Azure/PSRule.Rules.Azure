---
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Azure Database for MySQL
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MySQL.MaintenanceWindow/
---

# Customer-controlled maintenance window configuration

## SYNOPSIS

Configure a customer-controlled maintenance window for Azure Database for MySQL servers.

## DESCRIPTION

Azure Database for MySQL flexible servers undergo periodic maintenance to ensure your managed database remains secure, stable, and up-to-date. This maintenance includes applying security updates, system upgrades, and software patches.

Maintenance windows can be scheduled in two ways for each flexible server:

- System-Managed Schedule: The system automatically selects a one-hour window between 11 PM and 7 AM in your server’s regional time.
- Custom Schedule: You can specify a preferred maintenance window by choosing the day of the week and a one-hour time window.

By configuring a customer-controlled maintenance window, you can schedule updates to occur during a preferred time, ideally outside business hours, minimizing disruptions.

Only the flexible server deployment model supports customer-controlled maintenance windows.

## RECOMMENDATION

Consider using a customer-controlled maintenance window to efficiently schedule updates and minimize disruptions.

## EXAMPLES

### Configure with Azure template

To configure servers that pass this rule:

- Set the `properties.maintenanceWindow.customWindow` property to `Enabled`.

For example:

```json
{
  "type": "Microsoft.DBforMySQL/flexibleServers",
  "apiVersion": "2023-10-01-preview",
  "name": "[parameters('serverName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard_D16as",
    "tier": "GeneralPurpose"
  },
  "properties": {
    "administratorLogin": "[parameters('administratorLogin')]",
    "administratorLoginPassword": "[parameters('administratorLoginPassword')]",
    "createMode": "Default",
    "version": "[parameters('mysqlVersion')]",
    "maintenanceWindow": {
      "customWindow": "Enabled",
      "dayOfWeek": "0",
      "startHour": "1",
      "startMinute": "0"
    }
  }
}
```

### Configure with Bicep

To configure servers that pass this rule:

- Set the `properties.maintenanceWindow.customWindow` property to `Enabled`.

For example:

```bicep
resource mysqlDbServer 'Microsoft.DBforMySQL/flexibleServers@2023-10-01-preview' = {
  name: serverName
  location: location
  sku: {
    name: 'Standard_D16as'
    tier: 'GeneralPurpose'
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    createMode: 'Default'
    version: mysqlVersion
     maintenanceWindow: {
      customWindow: 'Enabled'
      dayOfWeek: 0
      startHour: 1
      startMinute: 0
    }
  }
}
```

## NOTES

The custom schedule maintenance window feature is only available for the flexible server deployment model.

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Scheduled maintenance in Azure Database for MySQL](https://learn.microsoft.com/azure/mysql/flexible-server/concepts-maintenance)
- [Select a maintenance window](https://learn.microsoft.com/azure/mysql/flexible-server/concepts-maintenance#select-a-maintenance-window)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbformysql/flexibleservers)
