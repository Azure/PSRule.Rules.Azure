---
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: Azure Database for MySQL
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MySQL.ZoneRedundantHA/
---

# Zone-Redundant High Availability

## SYNOPSIS

Deploy Azure Database for MySQL servers using zone-redundant high availability (HA) in supported regions to ensure high availability and resilience.

## DESCRIPTION

Azure Database for MySQL flexible servers allows configuration high availablity (HA) across availablity zones in supported regions.
Using availability zones improves resiliency of your solution to failures or disruptions isolated to a zone or data center.

Zone-redundant HA works by:

- Deploying two servers; a primary in one zone, and a secondary in a physically separate zone.
- Database and backup storage is also configured across zones and replicated.

The failover process ensures continuous operation by switching from the primary server to the standby replica server.
This process can be:

- Manual (Planned) Failover: Initiated by the user for maintenance or other operational reasons.
- Automatic (Unplanned) Failover: Triggered by Azure in response to failures such as hardware or network issues affecting the primary server.

Before opting for the zone-redundant HA model, review the documentation for additional limitations and critical information.
This includes understanding the latency impact between zones, cost implications, and any specific regional support constraints.

## RECOMMENDATION

Consider deploying flexible servers using zone-redundant high-availability to improve the resiliency of your databases.

## EXAMPLES

### Configure with Azure template

To configure servers that pass this rule:

- Set the `properties.highAvailability.mode` property to `ZoneRedundant`.

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
    "availabilityZone": "1",
    "highAvailability": {
      "mode": "ZoneRedundant",
      "standbyAvailabilityZone": "2"
     }
  }
}
```

### Configure with Bicep

To configure servers that pass this rule:

- Set the `properties.highAvailability.mode` property to `ZoneRedundant`.

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
    availabilityZone: 1
    highAvailability: {
      mode: ZoneRedundant,
      standbyAvailabilityZone: 2
     }
  }
}
```

<!-- external:avm avm/res/db-for-my-sql/flexible-server highAvailability -->

## NOTES

The zone-redundant HA model must be configured during the initial deployment. It is not possible to modify an existing server to include zone-redundant HA after it has been deployed.

The `Burstable` SKU tier is not supported.

Only a certain set of regions currently support the zone-redundant HA model.

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [High availability concepts in Azure Database for MySQL](https://learn.microsoft.com/azure/mysql/flexible-server/concepts-high-availability)
- [Zone-redundant HA architecture](https://learn.microsoft.com/azure/mysql/flexible-server/concepts-high-availability#zone-redundant-ha-architecture)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbformysql/flexibleservers)
