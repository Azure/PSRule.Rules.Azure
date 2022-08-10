---
severity: Critical
pillar: Security
category: Authentication
resource: SQL Database
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.AAD/
---

# Use AAD authentication with SQL databases

## SYNOPSIS

Use Azure Active Directory (AAD) authentication with Azure SQL databases.

## DESCRIPTION

Azure SQL Database offer two authentication models, Azure Active Directory (AAD) and SQL logins.
AAD authentication supports centialized identity management in addition to modern password protections.
Some of the benefits of AAD authentication over SQL authentication including:

- Support for Azure Multi-Factor Authentication (MFA).
- Conditional-based access with Conditional Access.

It is also possible to disable SQL authentication entirely.

## RECOMMENDATION

Consider using Azure Active Directory (AAD) authentication with SQL databases.
Additionally, consider disabling SQL authentication.

## EXAMPLES

### Configure with Azure template

To deploy logical SQL Servers that pass this rule:

- Set the `properties.administrators.administratorType` to `ActiveDirectory`.
- Set the `properties.administrators.login` to the administrator login object name.
- Set the `properties.administrators.sid` to the object ID GUID of the administrator user, group, or application.

For example:

```json
{
    "type": "Microsoft.Sql/servers",
    "apiVersion": "2022-02-01-preview",
    "name": "[parameters('name')]",
    "location": "[parameters('location')]",
    "properties": {
        "minimalTlsVersion": "1.2",
        "administrators": {
            "administratorType": "ActiveDirectory",
            "login": "[parameters('adminLogin')]",
            "principalType": "Group",
            "sid": "[parameters('adminPrincipalId')]",
            "tenantId": "[tenant().tenantId]"
        }
    }
}
```

Alternatively, you can configure the `Microsoft.Sql/servers/administrators` sub-resource.
To deploy `Microsoft.Sql/servers/administrators` sub-resources that pass this rule:

- Set the `properties.administratorType` to `ActiveDirectory`.
- Set the `properties.login` to the administrator login object name.
- Set the `properties.sid` to the object ID GUID of the administrator user, group, or application.

For example:

```json
{
    "type": "Microsoft.Sql/servers/administrators",
    "apiVersion": "2022-02-01-preview",
    "name": "[format('{0}/{1}', parameters('name'), 'ActiveDirectory')]",
    "properties": {
        "administratorType": "ActiveDirectory",
        "login": "[parameters('adminLogin')]",
        "sid": "[parameters('adminPrincipalId')]"
    },
    "dependsOn": [
        "[resourceId('Microsoft.Sql/servers', parameters('name'))]"
    ]
}
```

### Configure with Bicep

To deploy logical SQL Servers that pass this rule:

- Set the `properties.administrators.administratorType` to `ActiveDirectory`.
- Set the `properties.administrators.login` to the administrator login object name.
- Set the `properties.administrators.sid` to the object ID GUID of the administrator user, group, or application.

For example:

```bicep
resource server 'Microsoft.Sql/servers@2022-02-01-preview' = {
  name: name
  location: location
  properties: {
    minimalTlsVersion: '1.2'
    administrators: {
      administratorType: 'ActiveDirectory'
      login: adminLogin
      principalType: 'Group'
      sid: adminPrincipalId
      tenantId: tenant().tenantId
    }
  }
}
```

Alternatively, you can configure the `Microsoft.Sql/servers/administrators` sub-resource.
To deploy `Microsoft.Sql/servers/administrators` sub-resources that pass this rule:

- Set the `properties.administratorType` to `ActiveDirectory`.
- Set the `properties.login` to the administrator login object name.
- Set the `properties.sid` to the object ID GUID of the administrator user, group, or application.

For example:

```bicep
resource sqlAdministrator 'Microsoft.Sql/servers/administrators@2022-02-01-preview' = {
  parent: server
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: adminLogin
    sid: adminPrincipalId
  }
}
```

### Configure with Azure CLI

```bash
az sql server ad-admin create -s '<server_name>' -g '<resource_group>' -u '<user_name>' -i '<object_id>'
```

### Configure with Azure PowerShell

```powershell
Set-AzSqlServerActiveDirectoryAdministrator -ResourceGroupName '<resource_group>' -ServerName '<server_name>' -DisplayName '<user_name>'
```

## NOTES

In newer API versions the `properties.administrators` property can be configured.
Azure AD authentication can also be configured using the `Microsoft.Sql/servers/administrators` sub-resource.

If both the `properties.administrators` property and `Microsoft.Sql/servers/administrators` are set,
the sub-resoure will override the property.

## LINKS

- [Use modern password protection](https://docs.microsoft.com/azure/architecture/framework/security/design-identity-authentication#use-modern-password-protection)
- [Configure and manage Azure AD authentication with Azure SQL](https://docs.microsoft.com/azure/azure-sql/database/authentication-aad-configure)
- [Using multi-factor Azure Active Directory authentication](https://docs.microsoft.com/azure/azure-sql/database/authentication-mfa-ssms-overview)
- [Conditional Access with Azure SQL Database and Azure Synapse Analytics](https://docs.microsoft.com/azure/azure-sql/database/conditional-access-configure)
- [Azure AD-only authentication with Azure SQL](https://docs.microsoft.com/azure/azure-sql/database/authentication-azure-ad-only-authentication)
- [Azure Policy for Azure Active Directory only authentication with Azure SQL](https://docs.microsoft.com/azure/azure-sql/database/authentication-azure-ad-only-authentication-policy)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.sql/servers/administrators)
