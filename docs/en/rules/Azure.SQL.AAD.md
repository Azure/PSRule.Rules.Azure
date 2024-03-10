---
reviewed: 2024-03-11
severity: Critical
pillar: Security
category: SE:05 Identity and access management
resource: SQL Database
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.AAD/
---

# Use Entra ID authentication with SQL databases

## SYNOPSIS

Use Entra ID authentication with Azure SQL databases.

## DESCRIPTION

Azure SQL Database offer two authentication models, Entra ID (previously known as Azure AD) and SQL authentication.
Entra ID authentication supports centralized identity management in addition to modern password protections.
Some of the benefits of Entra ID authentication over SQL authentication including:

- Support for Azure Multi-Factor Authentication (MFA).
- Conditional-based access with Conditional Access.

It is also possible to disable SQL authentication entirely and only use Entra ID authentication.

## RECOMMENDATION

Consider using Entra ID authentication with SQL databases.
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
  "apiVersion": "2022-11-01-preview",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "publicNetworkAccess": "Disabled",
    "minimalTlsVersion": "1.2",
    "administrators": {
      "azureADOnlyAuthentication": true,
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
    "server"
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
resource server 'Microsoft.Sql/servers@2022-11-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publicNetworkAccess: 'Disabled'
    minimalTlsVersion: '1.2'
    administrators: {
      azureADOnlyAuthentication: true
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
Entra ID authentication can also be configured using the `Microsoft.Sql/servers/administrators` sub-resource.

If both the `properties.administrators` property and `Microsoft.Sql/servers/administrators` are set,
the sub-resource will override the property.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-sql-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Configure and manage Microsoft Entra authentication with Azure SQL](https://learn.microsoft.com/azure/azure-sql/database/authentication-aad-configure)
- [Using Microsoft Entra multi-factor authentication](https://learn.microsoft.com/azure/azure-sql/database/authentication-mfa-ssms-overview)
- [Conditional Access with Azure SQL Database and Azure Synapse Analytics](https://learn.microsoft.com/azure/azure-sql/database/conditional-access-configure)
- [Microsoft Entra-only authentication with Azure SQL](https://learn.microsoft.com/azure/azure-sql/database/authentication-azure-ad-only-authentication)
- [Azure Policy for Microsoft Entra-only authentication with Azure SQL](https://learn.microsoft.com/azure/azure-sql/database/authentication-azure-ad-only-authentication-policy)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/servers)
