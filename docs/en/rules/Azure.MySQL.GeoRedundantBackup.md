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

Geo-redundant backup helps to protect your Azure Database for MySQL Servers against outages impacting backup storage in the primary region and allows you to restore your server to the geo-paired region in the event of a disaster.

When the backups are stored in geo-redundant backup storage, they are not only stored within the region in which your server is hosted, but are also replicated to a paired data center. Both the Azure Database for MySQL Flexible Server and the Azure Database for MySQL Single Server deployment model supports geo-redundant backup.

For the flexible deployment model the geo-redundant backup is supported for all tiers, but for the single deployment model either `General Purpose` or `Memory Optimized` tier is required.

Check out the `NOTES` section for more details about geo-redundant backup for each of the deployment models.

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
- [Azure template reference flexible servers](https://learn.microsoft.com/azure/templates/microsoft.dbformysql/flexibleservers)
- [Azure template reference single servers](https://learn.microsoft.com/azure/templates/microsoft.dbformysql/servers)
