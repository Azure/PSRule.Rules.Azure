---
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Azure Database for MySQL
resourceType: Microsoft.DBforMySQL/flexibleServers,Microsoft.DBforMySQL/flexibleServers/configurations
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MySQL.AADOnly/
---

# Entra ID only authentication

## SYNOPSIS

Ensure Entra ID only authentication is enabled with Azure Database for MySQL databases.

## DESCRIPTION

Azure Database for MySQL supports authentication with MySQL logins and Entra ID (previously Azure AD) authentication.

By default, authentication with MySQL logins is enabled.
MySQL logins are unable to provide sufficient protection for identities.
Entra ID authentication provides:

- Strong protection controls including conditional access.
- Identity governance.
- Privileged identity management.

Once you decide to use Entra ID authentication, you can disable authentication with MySQL logins.

Entra ID only authentication is only supported for the flexible server deployment model with MySQL 5.7 and newer.

## RECOMMENDATION

Consider using Entra ID only authentication.
Also consider using Azure Policy for Entra ID only authentication with Azure Database for MySQL.

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
    value: 'ON'
    source: 'user-override'
  }
}
```

## NOTES

The Entra ID admin must be set before enabling Entra ID only authentication.
Entra ID only authentication is only supported for the flexible server deployment model.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-database-for-mysql-flexible-server-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Microsoft Entra authentication for Azure Database for MySQL - Flexible Server](https://learn.microsoft.com/azure/mysql/flexible-server/concepts-azure-ad-authentication)
- [Azure security baseline for Azure Database for MySQL - Flexible Server](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-database-for-mysql-flexible-server-security-baseline)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.dbformysql/flexibleservers/configurations)
