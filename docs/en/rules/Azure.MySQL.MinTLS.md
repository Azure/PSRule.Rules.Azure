---
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: Azure Database for MySQL
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MySQL.MinTLS/
---

# MySQL DB server minimum TLS version

## SYNOPSIS

MySQL DB servers should reject TLS versions older than 1.2.

## DESCRIPTION

The minimum version of TLS that MySQL DB servers accept is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Azure lets you disable outdated protocols and require connections to use a minimum of TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 is accepted.

## RECOMMENDATION

Consider configuring the minimum supported TLS version to be 1.2.

## EXAMPLES

### Configure with Azure template

To deploy servers that pass this rule:

- Set the `properties.minimalTlsVersion` property to `TLS1_2`.

For example:

```json
{
  "type": "Microsoft.DBforMySQL/servers",
  "apiVersion": "2017-12-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "GP_Gen5_2",
    "tier": "GeneralPurpose",
    "capacity": 2,
    "size": "5120",
    "family": "Gen5"
  },
  "properties": {
    "createMode": "Default",
    "version": "8.0",
    "administratorLogin": "[parameters('administratorLogin')]",
    "administratorLoginPassword": "[parameters('administratorLoginPassword')]",
    "minimalTlsVersion": "TLS1_2",
    "sslEnforcement": "Enabled",
    "publicNetworkAccess": "Disabled",
    "storageProfile": {
      "storageMB": 5120,
      "backupRetentionDays": 7,
      "geoRedundantBackup": "Enabled"
    }
  }
}
```

### Configure with Bicep

To deploy servers that pass this rule:

- Set the `properties.minimalTlsVersion` property to `TLS1_2`.

For example:

```bicep
resource singleServer 'Microsoft.DBforMySQL/servers@2017-12-01' = {
  name: name
  location: location
  sku: {
    name: 'GP_Gen5_2'
    tier: 'GeneralPurpose'
    capacity: 2
    size: '5120'
    family: 'Gen5'
  }
  properties: {
    createMode: 'Default'
    version: '8.0'
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    minimalTlsVersion: 'TLS1_2'
    sslEnforcement: 'Enabled'
    publicNetworkAccess: 'Disabled'
    storageProfile: {
      storageMB: 5120
      backupRetentionDays: 7
      geoRedundantBackup: 'Enabled'
    }
  }
}
```

## NOTES

This rule is only applicable for the Azure Database for MySQL Single Server deployment model.

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#data-in-transit)
- [TLS enforcement in Azure Database for MySQL](https://learn.microsoft.com/azure/mysql/concepts-ssl-connection-security#tls-enforcement-in-azure-database-for-mysql)
- [Set TLS configurations for Azure Database for MySQL](https://learn.microsoft.com/azure/mysql/howto-tls-configurations#set-tls-configurations-for-azure-database-for-mysql)
- [TLS encryption in Azure](https://learn.microsoft.com/azure/security/fundamentals/encryption-overview#tls-encryption-in-azure)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbformysql/servers)
