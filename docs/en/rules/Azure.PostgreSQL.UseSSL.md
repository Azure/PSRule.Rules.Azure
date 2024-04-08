---
reviewed: 2024-04-09
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: Azure Database for PostgreSQL
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PostgreSQL.UseSSL/
ms-content-id: 80d34e65-8ab5-4cf3-a0dd-3b5e56e06f40
---

# Enforce encrypted PostgreSQL connections

## SYNOPSIS

Enforce encrypted PostgreSQL connections.

## DESCRIPTION

Azure Database for PostgreSQL is configured to only accept encrypted connections by default.
When the setting _enforce SSL connections_ is disabled, encrypted and unencrypted connections are permitted.
This does not indicate that unencrypted connections are being used.

Unencrypted communication to PostgreSQL server instances could allow disclosure of information to an untrusted party.

## RECOMMENDATION

Azure Database for PostgreSQL should be configured to only accept encrypted connections.
Unless explicitly required, consider enabling _enforce SSL connections_.

Also consider using Azure Policy to audit or enforce this configuration.

## EXAMPLES

### Configure with Azure template

To deploy servers that pass this rule:

- Set the `properties.sslEnforcement` property to `Enabled`.

For example:

```json
{
  "type": "Microsoft.DBforPostgreSQL/servers",
  "apiVersion": "2017-12-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "createMode": "Default",
    "administratorLogin": "[parameters('localAdministrator')]",
    "administratorLoginPassword": "[parameters('localAdministratorPassword')]",
    "minimalTlsVersion": "TLS1_2",
    "sslEnforcement": "Enabled",
    "publicNetworkAccess": "Disabled",
    "version": "11"
  }
}
```

### Configure with Bicep

To deploy servers that pass this rule:

- Set the `properties.sslEnforcement` property to `Enabled`.

For example:

```bicep
resource single 'Microsoft.DBforPostgreSQL/servers@2017-12-01' = {
  name: name
  location: location
  properties: {
    createMode: 'Default'
    administratorLogin: localAdministrator
    administratorLoginPassword: localAdministratorPassword
    minimalTlsVersion: 'TLS1_2'
    sslEnforcement: 'Enabled'
    publicNetworkAccess: 'Disabled'
    version: '11'
  }
}
```

## NOTES

This rule is not applicable to PostgreSQL using the flexible server model.

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#data-in-transit)
- [Configure SSL connectivity in Azure Database for PostgreSQL](https://learn.microsoft.com/azure/postgresql/single-server/concepts-ssl-connection-security)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbforpostgresql/servers)
