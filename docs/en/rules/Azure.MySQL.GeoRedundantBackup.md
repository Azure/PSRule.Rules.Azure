---
severity: Important
pillar: Reliability
category: Target and non-functional requirements
resource: Azure Database for MySQL
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MySQL.GeoRedundantBackup/
---

# Configure geo-redundant backup

## SYNOPSIS

Azure Database for MySQL should store backups in a geo-redundant storage.

## DESCRIPTION

### Azure Database for MySQL Flexible Server

Azure Database for MySQL stores multiple copies of your backups so that your data is protected from planned and unplanned events, including transient hardware failures, network or power outages, and massive natural disasters. Azure Database for MySQL provides the flexibility to choose between locally redundant, zone-redundant or geo-redundant backup storage in Basic, General Purpose and Business Critical tiers. By default, Azure Database for MySQL server backup storage is locally redundant for servers with same-zone high availability (HA) or no high availability configuration, and zone redundant for servers with zone-redundant HA configuration.

**Geo-Redundant backup storage**: When the backups are stored in geo-redundant backup storage, multiple copies are not only stored within the region in which your server is hosted, but are also replicated to its geo-paired region. This provides better protection and ability to restore your server in a different region in the event of a disaster. Also this provides at least 99.99999999999999% (16 9's) durability of Backups objects over a given year.One can enable Geo-Redundancy option at server create time to ensure geo-redundant backup storage. Additionally, you can move from locally redundant storage to geo-redundant storage post server create. Geo redundancy is supported for servers hosted in any of the Azure paired regions.

**Note** Zone-redundant High Availability to support zone redundancy is current surfaced as a create time operation only. Currently, for a Zone-redundant High Availability server geo-redundancy can only be enabled/disabled at server create time.

#### Moving from other backup storage options to geo-redundant backup storage

You can move your existing backups storage to geo-redundant storage using the following suggested ways:

- **Moving from locally redundant to geo-redundant backup storage** - In order to move your backup storage from locally redundant storage to geo-redundant storage, you can change the Compute + Storage server configuration from Azure portal to enable Geo-redundancy for the locally redundant source server. Same Zone Redundant HA servers can also be restored as a geo-redundant server in a similar fashion as the underlying backup storage is locally redundant for the same.

- **Moving from zone-redundant to geo-redundant backup storage** - Azure Database for MySQL does not support zone-redundant storage to geo-redundant storage conversion through Compute + Storage settings change or point-in-time restore operation. In order to move your backup storage from zone-redundant storage to geo-redundant storage, creating a new server and migrating the data using dump and restore is the only supported option.

### Azure Database for MySQL Single Server

Azure Database for MySQL provides the flexibility to choose between locally redundant or geo-redundant backup storage in the General Purpose and Memory Optimized tiers. When the backups are stored in geo-redundant backup storage, they are not only stored within the region in which your server is hosted, but are also replicated to a paired data center. This geo-redundancy provides better protection and ability to restore your server in a different region in the event of a disaster. The Basic tier only offers locally redundant backup storage.

**Important** Configuring locally redundant or geo-redundant storage for backup is only allowed during server create. Once the server is provisioned, you cannot change the backup storage redundancy option. In order to move your backup storage from locally redundant storage to geo-redundant storage, creating a new server and migrating the data using dump and restore is the only supported option.

## RECOMMENDATION

Configure geo-redundant backup for Azure Database for MySQL.

## EXAMPLES

### Configure with Azure template

To deploy Azure Database for MySQL Flexible Servers that pass this rule:

- Set the `properties.backup.geoRedundantBackup` property to the value `'Enabled'`.

For example:

```json
{
  "type": "Microsoft.DBforMySQL/flexibleServers",
  "apiVersion": "2021-12-01-preview",
  "name": "[parameters('serverName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard_D16as",
    "tier": "GeneralPurpose"
  },
  "properties": {
    "administratorLogin": "[parameters('administratorLogin')]",
    "administratorLoginPassword": "[parameters('administratorLoginPassword')]",
    "storage": {
      "autoGrow": "Enabled",
      "iops": "[parameters('StorageIops')]",
      "storageSizeGB": "[parameters('StorageSizeGB')]"
    },
    "createMode": "Default",
    "version": "[parameters('mysqlVersion')]",
    "backup": {
      "backupRetentionDays": 7,
      "geoRedundantBackup": "Enabled"
    },
    "highAvailability": {
      "mode": "Disabled"
    }
  }
}
```

To deploy Azure Database for MySQL Single Servers that pass this rule:

- Set the `properties.storageProfile.geoRedundantBackup` property to the value `'Enabled'`.

For example:

```json
{
  "type": "Microsoft.DBforMySQL/servers",
  "apiVersion": "2017-12-01",
  "name": "[parameters('serverName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "[parameters('skuName')]",
    "tier": "GeneralPurpose",
    "capacity": "[parameters('skuCapacity')]",
    "size": "[format('{0}', parameters('SkuSizeMB'))]",
    "family": "[parameters('skuFamily')]"
  },
  "properties": {
    "createMode": "Default",
    "version": "[parameters('mysqlVersion')]",
    "administratorLogin": "[parameters('administratorLogin')]",
    "administratorLoginPassword": "[parameters('administratorLoginPassword')]",
    "storageProfile": {
      "storageMB": "[parameters('SkuSizeMB')]",
      "backupRetentionDays": 7,
      "geoRedundantBackup": "Enabled"
    }
  }
}
```

### Configure with Bicep

To deploy Azure Database for MySQL Flexible Servers that pass this rule:

- Set the `properties.backup.geoRedundantBackup` property to the value `'Enabled'`.

For example:

```bicep
resource mysqlDbServer 'Microsoft.DBforMySQL/flexibleServers@2021-12-01-preview' = {
  name: serverName
  location: location
  sku: {
    name: 'Standard_D16as'
    tier: 'GeneralPurpose'
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storage: {
      autoGrow: 'Enabled'
      iops: StorageIops
      storageSizeGB: StorageSizeGB
    }
    createMode: 'Default'
    version: mysqlVersion
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Enabled'
    }
    highAvailability: {
      mode: 'Disabled'
    }
  }
}
```

To deploy Azure Database for MySQL Single Servers that pass this rule:

- Set the `properties.storageProfile.geoRedundantBackup` property to the value `'Enabled'`.

For example:

```bicep
resource mysqlDbServer 'Microsoft.DBforMySQL/servers@2017-12-01' = {
  name: serverName
  location: location
  sku: {
    name: skuName
    tier: 'GeneralPurpose'
    capacity: skuCapacity
    size: '${SkuSizeMB}'
    family: skuFamily
  }
  properties: {
    createMode: 'Default'
    version: mysqlVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storageProfile: {
      storageMB: SkuSizeMB
      backupRetentionDays: 7
      geoRedundantBackup: 'Enabled'
    }
  }
}
```

## NOTES

This rule is applicable for both the Azure Database for MySQL Flexible Server deployment model and the Azure Database for MySQL Single Server deployment model.

For the Single Server deployment model, it runs only against `'General Purpose'` and `'Memory Optimized'` tiers. The `'Basic'` tier does not support geo-redundant backup storage.

## LINKS

- [Target and non-functional requirements](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-requirements)
- [Backup and restore in Azure Database for MySQL flexible servers](https://learn.microsoft.com/azure/mysql/flexible-server/concepts-backup-restore)
- [Backup and restore in Azure Database for MySQL single servers](https://learn.microsoft.com/azure/mysql/single-server/concepts-backup)
- [Azure template reference flexible servers](https://learn.microsoft.com/en-us/azure/templates/microsoft.dbforpostgresql/flexibleservers)
- [Azure template reference single servers](https://learn.microsoft.com/azure/templates/microsoft.dbformysql/servers)
