---
severity: Important
pillar: Reliability
category: Target and non-functional requirements
resource: Azure Database for PostgreSQL
resourceType: Microsoft.DBforPostgreSQL/servers,Microsoft.DBforPostgreSQL/flexibleServers
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PostgreSQL.GeoRedundantBackup/
---

# Configure geo-redundant backup

## SYNOPSIS

Azure Database for PostgreSQL should store backups in a geo-redundant storage.

## DESCRIPTION

Geo-redundant backup helps to protect your Azure Database for PostgreSQL Servers against outages impacting backup storage in the primary region and allows you to restore your server to the geo-paired region in the event of a disaster.

When the backups are stored in geo-redundant backup storage, they are not only stored within the region in which your server is hosted, but are also replicated to a paired data center.
Both the Azure Database for PostgreSQL Flexible Server and the Azure Database for PostgreSQL Single Server deployment model supports geo-redundant backup.

For the flexible deployment model the geo-redundant backup is supported for all tiers, but for the single deployment model either `General Purpose` or `Memory Optimized` tier is required.

Check out the `NOTES` and the `LINKS` section for more details about geo-redundant backup for each of the deployment models.

## RECOMMENDATION

Configure geo-redundant backup for Azure Database for PostgreSQL.

## EXAMPLES

### Configure with Azure template

To deploy Azure Database for PostgreSQL Flexible Servers that pass this rule:

- Set the `properties.backup.geoRedundantBackup` property to the value `'Enabled'`.

For example:

```json
{
  "type": "Microsoft.DBforPostgreSQL/flexibleServers",
  "apiVersion": "2022-01-20-preview",
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
      "storageSizeGB": "[parameters('StorageSizeGB')]"
    },
    "createMode": "Default",
    "version": "[parameters('postgresqlVersion')]",
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

To deploy Azure Database for PostgreSQL Single Servers that pass this rule:

- Set the `properties.storageProfile.geoRedundantBackup` property to the value `'Enabled'`.

For example:

```json
{
  "type": "Microsoft.DBforPostgreSQL/servers",
  "apiVersion": "2017-12-01",
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
    "version": "[parameters('postgresqlVersion')]",
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

To deploy Azure Database for PostgreSQL Flexible Servers that pass this rule:

- Set the `properties.backup.geoRedundantBackup` property to the value `'Enabled'`.

For example:

```bicep
resource postgresqlDbServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-01-20-preview' = {
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
      storageSizeGB: StorageSizeGB
    }
    createMode: 'Default'
    version: postgresqlVersion
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

To deploy Azure Database for PostgreSQL Single Servers that pass this rule:

- Set the `properties.storageProfile.geoRedundantBackup` property to the value `'Enabled'`.

For example:

```bicep
resource postgresqlDbServer 'Microsoft.DBforPostgreSQL/servers@2017-12-01' = {
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
    version: postgresqlVersion
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

This rule is applicable for both the Azure Database for PostgreSQL Flexible Server deployment model and the Azure Database for PostgreSQL Single Server deployment model.

For the Single Server deployment model, it runs only against `'General Purpose'` and `'Memory Optimized'` tiers. The `'Basic'` tier does not support geo-redundant backup storage.

## LINKS

- [Target and non-functional requirements](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-requirements)
- [Backup and restore in Azure Database for PostgreSQL flexible servers](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-backup-restore)
- [Backup and restore in Azure Database for PostgreSQL single servers](https://learn.microsoft.com/azure/postgresql/single-server/concepts-backup)
- [Azure deployment reference flexible servers](https://learn.microsoft.com/azure/templates/microsoft.dbforpostgresql/flexibleservers)
- [Azure deployment reference single servers](https://learn.microsoft.com/azure/templates/microsoft.dbforpostgresql/servers)
