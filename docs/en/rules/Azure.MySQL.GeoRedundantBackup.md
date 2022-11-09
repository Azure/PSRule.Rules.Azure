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

Azure Database for MySQL provides the flexibility to choose between locally redundant or geo-redundant backup storage in the General Purpose and Memory Optimized tiers. When the backups are stored in geo-redundant backup storage, they are not only stored within the region in which your server is hosted, but are also replicated to a paired data center. This geo-redundancy provides better protection and ability to restore your server in a different region in the event of a disaster. The Basic tier only offers locally redundant backup storage.

**Important** Configuring locally redundant or geo-redundant storage for backup is only allowed during server create. Once the server is provisioned, you cannot change the backup storage redundancy option. In order to move your backup storage from locally redundant storage to geo-redundant storage, creating a new server and migrating the data using dump and restore is the only supported option.

## RECOMMENDATION

Configure geo-redundant backup for Azure Database for MySQL.

## EXAMPLES

### Configure with Azure template

To deploy Azure Database for MySQL servers that pass this rule:

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

To deploy Azure Database for MySQL servers that pass this rule:

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

This rule is only applicable for Azure Database for MySQL servers deployed in the Single Server deployment model with `'General Purpose'` and `'Memory Optimized'` tiers. The `'Basic'` tier does not support geo-redundant backup storage.

Currently this rule does not run against Azure Database for MySQL using the Flexible Server deployment model.

## LINKS

- [Target and non-functional requirements](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-requirements)
- [Backup and restore in Azure Database for MySQL](https://learn.microsoft.com/azure/mysql/single-server/concepts-backup)
- [Azure template reference](https://learn.microsoft.com/azure/templates/microsoft.dbformysql/servers)
