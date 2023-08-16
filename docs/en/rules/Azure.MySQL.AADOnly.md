---
severity: Important
pillar: Security
category: Identity and access management
resource: Azure Database for MySQL
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MySQL.AADOnly/
---

# Azure AD-only authentication

## SYNOPSIS

Ensure Azure AD-only authentication is enabled with Azure Database for MySQL databases.

## DESCRIPTION

Azure Database for MySQL supports authentication with MySQL logins and Azure AD authentication.

By default, authentication with MySQL logins is enabled.
MySQL logins are unable to provide sufficient protection for identities.
Azure AD authentication provides strong protection controls including conditional access, identity governance, and privileged identity management.

Once you decide to use Azure AD authentication, you can disable authentication with MySQL logins.

Azure AD-only authentication is only supported for the flexible server deployment model with MySQL 5.7 and newer.

## RECOMMENDATION

Consider using Azure AD-only authentication.
Also consider using Azure Policy for Azure AD-only authentication with Azure Database for MySQL.

## EXAMPLES

### Configure with Azure template

To deploy Azure Database for MySQL flexible servers that pass this rule:

- Configure the `Microsoft.DBforMySQL/flexibleServers/configurations` sub-resource.
- Set the `name` to `aad_auth_only`.
- Set the `properties.value` to `ON`.
- Set the `properties.source` to `user-override`.

For example:

```json
{
  "type": "Microsoft.DBforMySQL/flexibleServers/configurations",
  "apiVersion": "2022-01-01",
  "name": "[format('{0}/{1}', parameters('serverName'), 'aad_auth_only')]",
  "properties": {
    "value": "ON",
    "source": "user-override"
  },
  "dependsOn": [
     "[resourceId('Microsoft.DBforMySQL/flexibleServers', parameters('serverName'))]"
  ]
}
```

### Configure with Bicep

To deploy Azure Database for MySQL flexible servers that pass this rule:

- Configure the `Microsoft.DBforMySQL/flexibleServers/configurations` sub-resource.
- Set the `name` to `aad_auth_only`.
- Set the `properties.value` to `ON`.
- Set the `properties.source` to `user-override`.

For example:

```bicep
resource aadOnly 'Microsoft.DBforMySQL/flexibleServers/configurations@2022-01-01' = {
  name: 'aad_auth_only'
  parent: mySqlFlexibleServer
  properties: {
    currentValue: 'ON'
  }
}
```

## NOTES

The Azure AD admin must be set before enabling Azure AD-only authentication.
Azure AD-only authentication is only suppored for the flexible server deployment model.

## LINKS

- [Use modern password protection](https://learn.microsoft.com/azure/architecture/framework/security/design-identity-authentication#use-modern-password-protection)
- [Active Directory authentication for Azure Database for MySQL - Flexible Server](https://learn.microsoft.com/azure/mysql/flexible-server/concepts-azure-ad-authentication)
- [Azure security baseline for Azure Database for MySQL - Flexible Server](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-database-for-mysql-flexible-server-security-baseline)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-database-for-mysql-flexible-server-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbformysql/flexibleservers/configurations)
