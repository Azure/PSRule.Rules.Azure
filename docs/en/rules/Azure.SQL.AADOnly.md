---
reviewed: 2023-07-26
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: SQL Database
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.AADOnly/
---

# Databases use Entra ID only authentication

## SYNOPSIS

Ensure Entra ID only authentication is enabled with Azure SQL Database.

## DESCRIPTION

Azure SQL Database supports authentication with SQL logins and Entra ID (previously known as Azure AD) authentication.
By default, authentication with SQL logins is enabled.
SQL logins are unable to provide sufficient protection for identities.

Entra ID authentication provides:

- Strong protection controls including conditional access, identity governance, and privileged identity management.
- Centralized identity management with Entra ID.

Additionally you can disable SQL authentication entirely, by enabling Entra ID only authentication.

Some features may have limitations when using Entra ID only authentication is enabled, including:

- Elastic jobs
- SQL Data Sync
- Change Data Capture (CDC)
- Transactional replication
- SQL insights

## RECOMMENDATION

Consider using Entra ID only authentication.
Also consider using Azure Policy for Entra ID only authentication with SQL Database.

## EXAMPLES

Azure AD-only authentication can be enabled in two different ways.

### Configure with Azure template

To deploy SQL Logical Servers that pass this rule:

- Set the `properties.administrators.azureADOnlyAuthentication` property to `true`.

For example:

```json
{
  "type": "Microsoft.Sql/servers",
  "apiVersion": "2022-05-01-preview",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned",
    "userAssignedIdentities": {}
  },
  "properties": {
    "administratorLogin": "[parameters('administratorLogin')]",
    "administratorLoginPassword": "[parameters('administratorLoginPassword')]",
    "administrators": {
      "administratorType": "ActiveDirectory",
      "azureADOnlyAuthentication": true,
      "login": "[parameters('login')]",
      "principalType": "[parameters('principalType')]",
      "sid": "[parameters('sid')]",
      "tenantId": "[parameters('tenantId')]"
    }
  }
}
```

Alternatively, you can configure the `Microsoft.Sql/servers/azureADOnlyAuthentications` sub-resource.
To deploy `Microsoft.Sql/servers/azureADOnlyAuthentications` sub-resources that pass this rule:

- Set the `properties.azureADOnlyAuthentication` property to `true`.

For example:

```json
{
  "type": "Microsoft.Sql/servers/azureADOnlyAuthentications",
  "apiVersion": "2022-05-01-preview",
  "name": "[format('{0}/{1}', parameters('name'), 'Default')]",
  "properties": {
    "azureADOnlyAuthentication": true
  },
  "dependsOn": [
    "[resourceId('Microsoft.Sql/servers', parameters('name'))]"
  ]
}
```

### Configure with Bicep

To deploy SQL Logical Servers that pass this rule:

- Set the `properties.administrators.azureADOnlyAuthentication` property to `true`.

For example:

```bicep
resource logicalServer 'Microsoft.Sql/servers@2022-05-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
    userAssignedIdentities: {}
  }
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
    administrators: {
      administratorType: 'ActiveDirectory'
      azureADOnlyAuthentication: true
      login: login
      principalType: principalType
      sid: sid
      tenantId: tenantId
    }
  }
}
```

Alternatively, you can configure the `Microsoft.Sql/servers/azureADOnlyAuthentications` sub-resource.
To deploy `Microsoft.Sql/servers/azureADOnlyAuthentications` sub-resources that pass this rule:

- Set the `properties.azureADOnlyAuthentication` property to `true`.

For example:

```bicep
resource aadOnly 'Microsoft.Sql/servers/azureADOnlyAuthentications@2022-05-01-preview' = {
  name: 'Default'
  parent: logicalServer
  properties: {
    azureADOnlyAuthentication: true
  }
}
```

<!-- external:avm avm/res/sql/server administrators -->

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Azure SQL Database should have Microsoft Entra-only authentication enabled during creation](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/SQL/SqlServer_ADOnlyEnabled_Deny.json)
  `/providers/Microsoft.Authorization/policyDefinitions/abda6d70-9778-44e7-84a8-06713e6db027`

## NOTES

The Entra ID admin must be set before enabling Entra ID only authentication.
A managed identity is required if an Entra ID service principal (Entra ID application) oversees creating and managing Entra ID users, groups, or applications in the logical server.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [Microsoft Entra-only authentication with Azure SQL](https://learn.microsoft.com/azure/azure-sql/database/authentication-azure-ad-only-authentication)
- [Configure and manage Microsoft Entra authentication with Azure SQL](https://learn.microsoft.com/azure/azure-sql/database/authentication-aad-configure)
- [Limitations for Microsoft Entra-only authentication in SQL Database](https://learn.microsoft.com/azure/azure-sql/database/authentication-azure-ad-only-authentication#limitations-for-azure-ad-only-authentication-in-sql-database)
- [Azure Policy for Microsoft Entra-only authentication with Azure SQL](https://learn.microsoft.com/en-gb/azure/azure-sql/database/authentication-azure-ad-only-authentication-policy)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/servers#managedinstanceexternaladministrator)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/servers/azureadonlyauthentications#managedinstanceazureadonlyauthproperties)
