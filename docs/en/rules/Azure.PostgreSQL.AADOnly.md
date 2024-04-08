---
reviewed: 2024-04-09
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Azure Database for PostgreSQL
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PostgreSQL.AADOnly/
---

# Entra ID only authentication with PostgreSQL databases

## SYNOPSIS

Ensure Entra ID only authentication is enabled with Azure Database for PostgreSQL databases.

## DESCRIPTION

Azure Database for PostgreSQL supports authentication with PostgreSQL logins and Entra ID authentication.

By default, authentication with PostgreSQL logins is enabled.
PostgreSQL logins are unable to provide sufficient protection for identities.
Entra ID authentication provides strong protection controls including conditional access, identity governance,
and privileged identity management.

Once you decide to use Entra ID authentication, you can disable authentication with PostgreSQL logins.

Entra ID only authentication is only supported for the flexible server deployment model.

## RECOMMENDATION

Consider using Entra ID only authentication.
Also consider using Azure Policy for Entra ID only authentication with Azure Database for PostgreSQL.

## EXAMPLES

### Configure with Azure template

To deploy Azure Database for PostgreSQL flexible servers that pass this rule:

- Set the `properties.authConfig.activeDirectoryAuth` property to `Enabled`.
- Set the `properties.authConfig.passwordAuth` property to `Disabled`.

For example:

```json
{
  "type": "Microsoft.DBforPostgreSQL/flexibleServers",
  "apiVersion": "2022-12-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard_D2ds_v4",
    "tier": "GeneralPurpose"
  },
  "properties": {
    "createMode": "Default",
    "authConfig": {
      "activeDirectoryAuth": "Enabled",
      "passwordAuth": "Disabled",
      "tenantId": "[tenant().tenantId]"
    },
    "version": "14",
    "storage": {
      "storageSizeGB": 32
    },
    "backup": {
      "backupRetentionDays": 7,
      "geoRedundantBackup": "Enabled"
    },
    "highAvailability": {
      "mode": "ZoneRedundant"
    }
  }
}
```

### Configure with Bicep

To deploy Azure Database for PostgreSQL flexible servers that pass this rule:

- Set the `properties.authConfig.activeDirectoryAuth` property to `Enabled`.
- Set the `properties.authConfig.passwordAuth` property to `Disabled`.

For example:

```bicep
resource flexible 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_D2ds_v4'
    tier: 'GeneralPurpose'
  }
  properties: {
    createMode: 'Default'
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Disabled'
      tenantId: tenant().tenantId
    }
    version: '14'
    storage: {
      storageSizeGB: 32
    }
    backup: {
      backupRetentionDays: 7
      geoRedundantBackup: 'Enabled'
    }
    highAvailability: {
      mode: 'ZoneRedundant'
    }
  }
}
```

## NOTES

The Entra ID admin must be set before enabling Entra ID only authentication.
Entra ID only authentication is only supported for the flexible server deployment model.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [How Microsoft Entra ID Works in Azure Database for PostgreSQL flexible server](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-azure-ad-authentication#how-azure-ad-works-in-flexible-server)
- [Use Microsoft Entra ID for authentication with Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/azure/postgresql/flexible-server/how-to-configure-sign-in-azure-ad-authentication)
- [Use Microsoft Entra ID for authentication with PostgreSQL](https://learn.microsoft.com/azure/postgresql/single-server/how-to-configure-sign-in-azure-ad-authentication)
- [Microsoft Entra authentication (Azure Database for PostgreSQL single Server vs Azure Database for PostgreSQL flexible server)](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-azure-ad-authentication#microsoft-entra-authentication-azure-database-for-postgresql-single-server-vs-azure-database-for-postgresql-flexible-server)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-database-for-postgresql-flexible-server-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbforpostgresql/flexibleservers#authconfig)
