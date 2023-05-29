---
severity: Critical
pillar: Security
category: Authentication
resource: Azure Database for PostgreSQL
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.PostgreSQL.AAD/
---

# Use AAD authentication with PostgreSQL databases

## SYNOPSIS

Use Azure Active Directory (AAD) authentication with Azure Database for PostgreSQL databases.

## DESCRIPTION

Azure Database for PostgreSQL offer two authentication models, Azure Active Directory (AAD) and PostgreSQL logins.
AAD authentication supports centialized identity management in addition to modern password protections.
Some of the benefits of AAD authentication over PostgreSQL authentication including:

- Support for Azure Multi-Factor Authentication (MFA).
- Conditional-based access with Conditional Access.

It is also possible to disable PostgreSQL authentication entirely for the flexible server deployment model.

## RECOMMENDATION

Consider using Azure Active Directory (AAD) authentication with Azure Database for PostgreSQL databases.
Additionally, consider disabling PostgreSQL authentication.

## EXAMPLES

### Configure with Azure template

To deploy Azure Database for PostgreSQL flexible servers that pass this rule:

- Configure the `Microsoft.DBforPostgreSQL/flexibleServers/administrators` sub-resource.
- Set the `properties.principalName` to the user principal name of the AAD administrator user, group, or application.
- Set the `properties.principalType` to the principal type used to represent the type of AAD administrator.
- Set the `properties.tenantId` to the tenant ID of the AAD administrator user, group, or application.

For example:

```json
{
    "type": "Microsoft.DBforPostgreSQL/flexibleServers/administrators",
    "apiVersion": "2022-12-01",
    "name": "[format('{0}/{1}', parameters('serverName'), parameters('name'))]",
      "properties": {
        "principalName": "[parameters('principalName')]",
        "principalType": "[parameters('principalType')]",
        "tenantId": "[parameters('tenantId')]"
      },
      "dependsOn": [
        "postgreSqlFlexibleServer"
      ]
}
```

### Configure with Bicep

To deploy Azure Database for PostgreSQL flexible servers that pass this rule:

- Configure the `Microsoft.DBforPostgreSQL/flexibleServers/administrators` sub-resource.
- Set the `properties.principalName` to the user principal name of the AAD administrator user, group, or application.
- Set the `properties.principalType` to the principal type used to represent the type of AAD administrator.
- Set the `properties.tenantId` to the tenant ID of the AAD administrator user, group, or application.

For example:

```bicep
resource aadAdmin 'Microsoft.DBforPostgreSQL/flexibleServers/administrators@2022-12-01' = {
  name: name
  parent: postgreSqlFlexibleServer
  properties: {
    principalName: principalName
    principalType: principalType
    tenantId: tenantId
  }
}
```

To deploy Azure Database for PostgreSQL single servers that pass this rule:

- Configure the `Microsoft.DBforPostgreSQL/servers/administrators` sub-resource.
- Set the `properties.administratorType` to `ActiveDirectory`.
- Set the `properties.login` to the AAD administrator login object name.
- Set the `properties.sid` to the object ID GUID of the AAD administrator user, group, or application.
- Set the `properties.tenantId` to the tenant ID of the AAD administrator user, group, or application.

For example:

```json
{
    "type": "Microsoft.DBforPostgreSQL/servers/administrators",
    "apiVersion": "2017-12-01",
    "name": "[format('{0}/{1}', parameters('serverName'), 'activeDirectory')]",
      "properties": {
        "administratorType": "ActiveDirectory",
        "login": "[parameters('location')]",
        "sid": "[parameters('sid')]",
        "tenantId": "[parameters('tenantId')]"
      },
      "dependsOn": [
        "postgreSqlSingleServer"
      ]
}
```

### Configure with Bicep

To deploy Azure Database for PostgreSQL single servers that pass this rule:

- Configure the `Microsoft.DBforPostgreSQL/servers/administrators` sub-resource.
- Set the `properties.administratorType` to `ActiveDirectory`.
- Set the `properties.login` to the AAD administrator login object name.
- Set the `properties.sid` to the object ID GUID of the AAD administrator user, group, or application.
- Set the `properties.tenantId` to the tenant ID of the AAD administrator user, group, or application.

For example:

```bicep
resource aadAdmin 'Microsoft.DBforPostgreSQL/servers/administrators@2017-12-01' = {
  name: 'activeDirectory'
  parent: postgreSqlSingleServer
  properties: {
    administratorType: 'ActiveDirectory'
    login: location
    sid: sid
    tenantId: tenantId
  }
}
```

## NOTES

The single server deployment model is limited to only one Azure AD admin at a time and does not support enforcing AAD-authentication only.

## LINKS

- [Use modern password protection](https://learn.microsoft.com/azure/architecture/framework/security/design-identity-authentication#use-modern-password-protection)
- [Azure Active Directory Authentication with PostgreSQL Flexible Server](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-azure-ad-authentication#how-azure-ad-works-in-flexible-server)
- [Use Azure AD for authentication with Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/azure/postgresql/flexible-server/how-to-configure-sign-in-azure-ad-authentication)
- [Use Azure AD for authentication with Azure Database for PostgreSQL - Single Server](https://learn.microsoft.com/azure/postgresql/single-server/how-to-configure-sign-in-azure-ad-authentication)
- [Azure Active Directory Authentication (Single Server VS Flexible Server)](https://learn.microsoft.com/azure/postgresql/flexible-server/concepts-azure-ad-authentication#azure-active-directory-authentication-single-server-vs-flexible-server)
- [Azure security baseline for Azure Database for PostgreSQL - Flexible Server](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-database-for-postgresql-flexible-server-security-baseline)
- [Azure security baseline for Azure Database for PostgreSQL - Single Server](https://learn.microsoft.com/security/benchmark/azure/baselines/postgresql-security-baseline)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-database-for-postgresql-flexible-server-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Azure deployment reference Flexible Server](https://learn.microsoft.com/azure/templates/microsoft.dbforpostgresql/flexibleservers/administrators)
- [Azure deployment reference Single Server](https://learn.microsoft.com/azure/templates/microsoft.dbforpostgresql/servers/administrators)
