---
severity: Critical
pillar: Security
category: SE:05 Identity and access management
resource: Azure Database for MySQL
resourceType: Microsoft.DBforMySQL/servers,Microsoft.DBforMySQL/flexibleServers,Microsoft.DBforMySQL/servers/administrators,Microsoft.DBforMySQL/flexibleServers/administrators
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MySQL.AAD/
---

# Use Entra ID authentication with MySQL databases

## SYNOPSIS

Use Entra ID authentication with Azure Database for MySQL databases.

## DESCRIPTION

Azure Database for MySQL offer two authentication models, Entra ID (previously Azure AD) and MySQL logins.
AAD authentication supports centralized identity management in addition to modern password protections.
Some of the benefits of Entra ID authentication over MySQL authentication including:

- Support for Azure Multi-Factor Authentication (MFA).
- Conditional-based access with Conditional Access.

It is also possible to disable MySQL authentication entirely for the flexible server deployment model.

## RECOMMENDATION

Consider using Entra ID authentication with Azure Database for MySQL databases.
Additionally, consider disabling MySQL authentication.

## EXAMPLES

### Configure with Azure template

To deploy Azure Database for MySQL flexible servers that pass this rule:

- Configure the `Microsoft.DBforMySQL/flexibleServers/administrators` sub-resource.
- Set the `properties.administratorType` to `ActiveDirectory`.
- Set the `properties.identityResourceId` to the resource ID of the user-assigned identity used for Entra ID authentication.
- Set the `properties.login` to the Entra ID administrator login object name.
- Set the `properties.sid` to the object ID GUID of the Entra ID administrator user, group, or application.
- Set the `properties.tenantId` to the tenant ID of the Entra ID administrator user, group, or application.

For example:

```json
{
  "type": "Microsoft.DBforMySQL/flexibleServers/administrators",
  "apiVersion": "2022-12-01-preview",
  "name": "[format('{0}/{1}', parameters('serverName'), 'activeDirectory')]",
  "properties": {
    "administratorType": "ActiveDirectory",
    "identityResourceId": "[parameters('identityResourceId')]",
    "login": "[parameters('login')]",
    "sid": "[parameters('sid')]",
    "tenantId": "[parameters('tenantId')]"
  },
  "dependsOn": [
    "mySqlFlexibleServer"
  ]
}
```

To deploy Azure Database for MySQL single servers that pass this rule:

- Configure the `Microsoft.DBforMySQL/servers/administrators` sub-resource.
- Set the `properties.administratorType` to `ActiveDirectory`.
- Set the `properties.login` to the Entra ID administrator login object name.
- Set the `properties.sid` to the object ID GUID of the Entra ID administrator user, group, or application.
- Set the `properties.tenantId` to the tenant ID of the Entra ID administrator user, group, or application.

For example:

```json
{
  "type": "Microsoft.DBforMySQL/servers/administrators",
  "apiVersion": "2017-12-01",
  "name": "[format('{0}/{1}', parameters('serverName'), 'activeDirectory')]",
  "properties": {
    "administratorType": "ActiveDirectory",
    "login": "[parameters('login')]",
    "sid": "[parameters('sid')]",
    "tenantId": "[parameters('tenantId')]"
  },
  "dependsOn": [
    "mySqlSingleServer"
  ]
}
```

### Configure with Bicep

To deploy Azure Database for MySQL flexible servers that pass this rule:

- Configure the `Microsoft.DBforMySQL/flexibleServers/administrators` sub-resource.
- Set the `properties.administratorType` to `ActiveDirectory`.
- Set the `properties.identityResourceId` to the resource ID of the user-assigned identity used for Entra ID authentication.
- Set the `properties.login` to the Entra ID administrator login object name.
- Set the `properties.sid` to the object ID GUID of the Entra ID administrator user, group, or application.
- Set the `properties.tenantId` to the tenant ID of the Entra ID administrator user, group, or application.

For example:

```bicep
resource aadAdmin 'Microsoft.DBforMySQL/flexibleServers/administrators@2021-12-01-preview' = {
  name: 'activeDirectory'
  parent: mySqlFlexibleServer
  properties: {
    administratorType: 'ActiveDirectory'
    identityResourceId: identityResourceId
    login: login
    sid: sid
    tenantId: tenantId
  }
}
```

To deploy Azure Database for MySQL single servers that pass this rule:

- Configure the `Microsoft.DBforMySQL/servers/administrators` sub-resource.
- Set the `properties.administratorType` to `ActiveDirectory`.
- Set the `properties.login` to the Entra ID administrator login object name.
- Set the `properties.sid` to the object ID GUID of the Entra ID administrator user, group, or application.
- Set the `properties.tenantId` to the tenant ID of the Entra ID administrator user, group, or application.

For example:

```bicep
resource aadAdmin 'Microsoft.DBforMySQL/servers/administrators@2017-12-01' = {
  name: 'activeDirectory'
  parent: mySqlSingleServer
  properties: {
    administratorType: 'ActiveDirectory'
    login: login
    sid: sid
    tenantId: tenantId
  }
}
```

## NOTES

For the flexible server deployment model a user-assigned identity is required in order to use Entra ID authentication.
The single server deployment model does not support enforcing Entra ID authentication only.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-database-for-mysql-flexible-server-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Microsoft Entra authentication for Azure Database for MySQL - Flexible Server](https://learn.microsoft.com/azure/mysql/flexible-server/concepts-azure-ad-authentication)
- [Use Microsoft Entra ID for authenticating with MySQL - Single Server](https://learn.microsoft.com/azure/mysql/single-server/concepts-azure-ad-authentication)
- [Azure security baseline for Azure Database for MySQL - Flexible Server](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-database-for-mysql-flexible-server-security-baseline)
- [Azure deployment reference Flexible Server](https://learn.microsoft.com/azure/templates/microsoft.dbformysql/flexibleservers/administrators)
- [Azure deployment reference Single Server](https://learn.microsoft.com/azure/templates/microsoft.dbformysql/servers/administrators)
