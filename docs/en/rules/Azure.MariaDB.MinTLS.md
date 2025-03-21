---
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: Azure Database for MariaDB
resourceType: Microsoft.DBforMariaDB/servers
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MariaDB.MinTLS/
---

# Minimum TLS version

## SYNOPSIS

Azure Database for MariaDB servers should reject TLS versions older than 1.2.

## DESCRIPTION

The minimum version of TLS that Azure Database for MariaDB servers accept is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Azure lets you disable outdated protocols and require connections to use a minimum of TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 is accepted.

## RECOMMENDATION

Configure the minimum supported TLS version to be 1.2.

## EXAMPLES

### Configure with Azure template

To deploy Azure Database for MariaDB Servers that pass this rule:

- Set the `properties.minimalTlsVersion` property to `TLS1_2`.

For example:

```json
{
  "type": "Microsoft.DBforMariaDB/servers",
  "apiVersion": "2018-06-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "[parameters('sku')]",
    "tier": "GeneralPurpose",
    "capacity": "[parameters('skuCapacity')]",
    "size": "[format('{0}', parameters('skuSizeMB'))]",
    "family": "Gen5"
  },
  "properties": {
    "sslEnforcement": "Enabled",
    "minimalTlsVersion": "TLS1_2",
    "createMode": "Default",
    "version": "10.3",
    "administratorLogin": "[parameters('administratorLogin')]",
    "administratorLoginPassword": "[parameters('administratorLoginPassword')]",
    "publicNetworkAccess": "Disabled",
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

- Set the `properties.minimalTlsVersion` property to `TLS1_2`.

For example:

```bicep
resource server 'Microsoft.DBforMariaDB/servers@2018-06-01' = {
  name: name
  location: location
  sku: {
    name: sku
    tier: 'GeneralPurpose'
    capacity: skuCapacity
    size: '${skuSizeMB}'
    family: 'Gen5'
  }
  properties: {
    sslEnforcement: 'Enabled'
    minimalTlsVersion: 'TLS1_2'
    createMode: 'Default'
    version: '10.3'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    publicNetworkAccess: 'Disabled'
    storageProfile: {
      storageMB: skuSizeMB
      backupRetentionDays: 7
      geoRedundantBackup: 'Enabled'
    }
  }
}
```

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#data-in-transit)
- [TLS enforcement in Azure Database for MariaDB](https://learn.microsoft.com/azure/mariadb/concepts-ssl-connection-security#tls-enforcement-in-azure-database-for-mariadb)
- [Set TLS configurations for Azure Database for MariaDB](https://learn.microsoft.com/azure/mariadb/howto-tls-configurations)
- [TLS encryption in Azure](https://learn.microsoft.com/azure/security/fundamentals/encryption-overview#tls-encryption-in-azure)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbformariadb/servers)
