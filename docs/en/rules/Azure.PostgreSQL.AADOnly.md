---
severity: Important
pillar: Security
category: Identity and access management
resource: Azure Database for PostgreSQL
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PostgreSQL.AADOnly/
---

# Azure AD-only authentication

## SYNOPSIS

Ensure Azure AD-only authentication is enabled with Azure Database for PostgreSQL databases.

## DESCRIPTION

Azure Database for PostgreSQL supports authentication with PostgreSQL logins and Azure AD authentication.

By default, authentication with PostgreSQL logins is enabled.
PostgreSQL logins are unable to provide sufficient protection for identities.
Azure AD authentication provides strong protection controls including conditional access, identity governance, and privileged identity management.

Once you decide to use Azure AD authentication, you can disable authentication with PostgreSQL logins.

Azure AD-only authentication is only supported for the flexible server deployment model.

## RECOMMENDATION

Consider using Azure AD-only authentication.
Also consider using Azure Policy for Azure AD-only authentication with Azure Database for PostgreSQL.

## EXAMPLES

### Configure with Azure template

To deploy Azure Database for PostgreSQL flexible servers that pass this rule:

- Set the `properties.authConfig.activeDirectoryAuth` property to `true`.
- Set the `properties.authConfig.passwordAuth` property to `false`.

For example:

```json
{
  "type": "Microsoft.DBforPostgreSQL/flexibleServers",
  "apiVersion": "2022-12-01",
  "name": "[parameters('serverName')]",
  "location": "[parameters('location')]",
  "properties": {
    "authConfig": {
      "activeDirectoryAuth": "Enabled",
      "passwordAuth": "Disabled",
      "tenantId": "[tenant().tenantId]"
    }
  }
}
```

### Configure with Bicep

To deploy Azure Database for PostgreSQL flexible servers that pass this rule:

- Set the `properties.authConfig.activeDirectoryAuth` property to `true`.
- Set the `properties.authConfig.passwordAuth` property to `false`.

For example:

```bicep
resource postgreSqlFlexibleServer 'Microsoft.DBforPostgreSQL/flexibleServers@2022-12-01' = {
  name: serverName
  location: location
  properties: {
    authConfig: {
      activeDirectoryAuth: 'Enabled'
      passwordAuth: 'Disabled'
      tenantId: tenant().tenantId
    }
  }
}
```

## NOTES

The Azure AD admin must be set before enabling Azure AD-only authentication.
Azure AD-only authentication is only suppored for the flexible server deployment model.

## LINKS

- [Use modern password protection](https://learn.microsoft.com/azure/architecture/framework/security/design-identity-authentication#use-modern-password-protection)
- [Use Azure AD for authentication with Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/azure/postgresql/flexible-server/how-to-configure-sign-in-azure-ad-authentication)
- [Azure Active Directory Authentication (Single Server VS Flexible Server)](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-azure-ad-authentication#azure-active-directory-authentication-single-server-vs-flexible-server)
- [Azure security baseline for Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-database-for-postgresql-flexible-server-security-baseline)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-database-for-postgresql-flexible-server-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbforpostgresql/flexibleservers#authconfig)
