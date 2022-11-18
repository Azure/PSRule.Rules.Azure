---
severity: Critical
pillar: Security
category: Data protection
resource: Azure Database for MariaDB
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MariaDB.UseSSL/
---

# Encrypted connections

## SYNOPSIS

Azure Database for MariaDB servers should only accept encrypted connections.

## DESCRIPTION

Azure Database for MariaDB is configured to only accept encrypted connections by default.
When the setting _enforce SSL connections_ is disabled, encrypted and unencrypted connections are permitted.
This does not indicate that unencrypted connections are being used.

Unencrypted communication to MariaDB server instances could allow disclosure of information to an untrusted party.

## RECOMMENDATION

Azure Database for MariaDB should be configured to only accept encrypted connections.
Unless explicitly required, consider enabling _enforce SSL connections_.

Also consider using Azure Policy to audit or enforce this configuration.

## EXAMPLES

### Configure with Azure template

To deploy Azure Database for MariaDB Servers that pass this rule:

- Set the `properties.sslEnforcement` property to `Enabled`.

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
    "sslEnforcement": "Enabled",
    "minimalTlsVersion": "TLS1_2",
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

- Set the `properties.sslEnforcement` property to `Enabled`.

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
    sslEnforcement: 'Enabled'
    minimalTlsVersion: 'TLS1_2'
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

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [SSL connectivity in Azure Database for MariaDB](https://learn.microsoft.com/azure/mariadb/concepts-ssl-connection-security)
- [Template reference](https://learn.microsoft.com/azure/templates/microsoft.dbformariadb/servers)
