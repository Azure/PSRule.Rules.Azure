---
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: Azure Database for MySQL
resourceType: Microsoft.DBforMySQL/servers
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MySQL.UseSSL/
ms-content-id: 2569c452-b0d4-45ca-a6df-72ff7e911be3
---

# Enforce encrypted MySQL connections

## SYNOPSIS

Enforce encrypted MySQL connections.

## DESCRIPTION

Azure Database for MySQL is configured to only accept encrypted connections by default.
When the setting _enforce SSL connections_ is disabled, encrypted and unencrypted connections are permitted.
This does not indicate that unencrypted connections are being used.

Unencrypted communication to MySQL server instances could allow disclosure of information to an untrusted party.

## RECOMMENDATION

Azure Database for MySQL should be configured to only accept encrypted connections.
Unless explicitly required, consider enabling _enforce SSL connections_.

Also consider using Azure Policy to audit or enforce this configuration.

## EXAMPLES

### Configure with Azure template

To deploy servers that pass this rule:

- Set the `properties.sslEnforcement` property to `Enabled`.

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

- Set the `properties.sslEnforcement` property to `Enabled`.

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
- [SSL connectivity in Azure Database for MySQL](https://learn.microsoft.com/azure/mysql/concepts-ssl-connection-security)
