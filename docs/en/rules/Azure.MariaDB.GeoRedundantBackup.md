---
severity: Important
pillar: Reliability
category: Target and non-functional requirements
resource: Azure Database for MariaDB
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MariaDB.GeoRedundantBackup/
---

# Configure geo-redundant backup

## SYNOPSIS

Azure Database for MariaDB should store backups in a geo-redundant storage.

## DESCRIPTION

Geo-redundant backup helps to protect your Azure Database for MariaDB Servers against outages impacting backup storage in the primary region and allows you to restore your server to the geo-paired region in the event of a disaster.

When the backups are stored in geo-redundant backup storage, they are not only stored within the region in which your server is hosted, but are also replicated to a paired data center.

Check out the `NOTES` and the `LINKS` section for more details about geo-redundant backup.

## RECOMMENDATION

Configure geo-redundant backup for Azure Database for MariaDB.

## EXAMPLES

### Configure with Azure template

To deploy Azure Database for MariaDB Servers that pass this rule:

- Set the `properties.storageProfile.geoRedundantBackup` property to `Enabled`.

For example:

```json
{
  "type": "Microsoft.DBforMariaDB/servers",
  "apiVersion": "2018-06-01",
  "name": "[parameters('serverName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "[parameters('skuName')]",
    "tier": "GeneralPurpose",
    "capacity": "[parameters('SkuCapacity')]",
    "size": "[format('{0}', parameters('skuSizeMB'))]",
    "family": "[parameters('skuFamily')]"
  },
  "properties": {
    "createMode": "Default",
    "version": "[parameters('mariadbVersion')]",
    "administratorLogin": "[parameters('administratorLogin')]",
    "administratorLoginPassword": "[parameters('administratorLoginPassword')]",
    "storageProfile": {
      "storageMB": "[parameters('skuSizeMB')]",
      "backupRetentionDays": 7,
      "geoRedundantBackup": "Enabled"
    }
  }
}
```

### Configure with Bicep

To deploy Azure Database for MariaDB Servers that pass this rule:

- Set the `properties.storageProfile.geoRedundantBackup` property to `Enabled`.

For example:

```bicep
resource mariaDbServer 'Microsoft.DBforMariaDB/servers@2018-06-01' = {
  name: serverName
  location: location
  sku: {
    name: skuName
    tier: 'GeneralPurpose'
    capacity: skuCapacity
    size: '${skuSizeMB}' 
    family: skuFamily
  }
  properties: {
    createMode: 'Default'
    version: mariadbVersion
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    storageProfile: {
      storageMB: skuSizeMB
      backupRetentionDays: 7
      geoRedundantBackup: 'Enabled'
    }
  }
}
```

## NOTES

This rule is only applicable for Azure Database for Maria DB Servers with `General Purpose` and `Memory Optimized` tiers. The `Basic` tier does not support geo-redundant backup storage.

## LINKS

- [Target and non-functional requirements](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-requirements)
- [Backup and restore in Azure Database for MariaDB](https://learn.microsoft.com/azure/mariadb/concepts-backup)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbformariadb/servers)
