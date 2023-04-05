---
severity: Important
pillar: Security
category: Identity and access management
resource: SQL Managed Instance
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.AADOnly/
---

# Azure AD-only authentication

## SYNOPSIS

Ensure Azure AD-only authentication is enabled with Azure SQL Database.

## DESCRIPTION

Azure SQL Database supports authentication with SQL logins and Azure AD authentication.

By default, authentication with SQL logins is enabled.
SQL logins are unable to provide sufficient protection for identities.
Azure AD authentication provides strong protection controls including conditional access, identity governance, and privileged identity management.

Once you decide to use Azure AD authentication, you can disable authentication with SQL logins.

## RECOMMENDATION

Consider using Azure AD-only authentication.
Also consider using Azure Policy for Azure AD-only authentication with SQL Database.

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

## NOTES

The Azure AD admin must be set before enabling Azure AD-only authentication. Managed identity is required if an Azure AD service principal (Azure AD application) oversees creating and managing Azure AD users, groups, or applications in the logical server.
## LINKS

- [Use modern password protection](https://learn.microsoft.com/azure/architecture/framework/security/design-identity-authentication#use-modern-password-protection)
- [Azure AD-only authentication with Azure SQL Database](https://learn.microsoft.com/azure/azure-sql/database/authentication-azure-ad-only-authentication)
- [Configure and manage Azure AD authentication with Azure SQL Database](https://learn.microsoft.com/azure/azure-sql/database/authentication-aad-configure)
- [Azure Policy for Azure AD-only authentication with Azure SQL Database](https://learn.microsoft.com/azure/azure-sql/database/authentication-azure-ad-only-authentication-policy)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/servers#managedinstanceexternaladministrator)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/servers/azureadonlyauthentications#managedinstanceazureadonlyauthproperties)
