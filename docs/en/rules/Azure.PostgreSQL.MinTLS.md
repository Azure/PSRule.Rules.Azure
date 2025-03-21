---
reviewed: 2024-04-09
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: Azure Database for PostgreSQL
resourceType: Microsoft.DBforPostgreSQL/servers
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PostgreSQL.MinTLS/
---

# PostgreSQL DB server minimum TLS version

## SYNOPSIS

PostgreSQL DB servers should reject TLS versions older than 1.2.

## DESCRIPTION

The minimum version of TLS that PostgreSQL DB servers accept is configurable.
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

- Set the `properties.minimalTlsVersion` property to `TLS1_2`.

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
- [TLS enforcement in Azure Database for PostgreSQL Single server](https://learn.microsoft.com/azure/postgresql/single-server/concepts-ssl-connection-security#tls-enforcement-in-azure-database-for-postgresql-single-server)
- [Set TLS configurations for Azure Database for PostgreSQL - Single server](https://learn.microsoft.com/azure/postgresql/single-server/how-to-tls-configurations#set-tls-configurations-for-azure-database-for-postgresql---single-server)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbforpostgresql/servers)
