---
severity: Important
pillar: Security
category: Identity and access management
resource: SQL Managed Instance
resourceType: Microsoft.Sql/managedInstances
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQLMI.AADOnly/
---

# Azure AD-only authentication

## SYNOPSIS

Ensure Azure AD-only authentication is enabled with Azure SQL Managed Instance.

## DESCRIPTION

Azure SQL Managed Instance supports authentication with SQL logins and Azure AD authentication.

By default, authentication with SQL logins is enabled.
SQL logins are unable to provide sufficient protection for identities.
Azure AD authentication provides strong protection controls including conditional access, identity governance, and privileged identity management.

Once you decide to use Azure AD authentication, you can disable authentication with SQL logins.

## RECOMMENDATION

Consider using Azure AD-only authentication.
Also consider using Azure Policy for Azure AD-only authentication with SQL Managed Instance.

## EXAMPLES

Azure AD-only authentication can be enabled in two different ways.

### Configure with Azure template

To deploy SQL Managed Instances that pass this rule:

- Set the `properties.administrators.azureADOnlyAuthentication` property to `true`.

For example:

```json
{
  "type": "Microsoft.Sql/managedInstances",
  "apiVersion": "2022-05-01-preview",
  "name": "[parameters('managedInstanceName')]",
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

Alternatively, you can configure the `Microsoft.Sql/managedInstances/azureADOnlyAuthentications` sub-resource.
To deploy `Microsoft.Sql/managedInstances/azureADOnlyAuthentications` sub-resources that pass this rule:

- Set the `properties.azureADOnlyAuthentication` property to `true`.

For example:

```json
{
  "type": "Microsoft.Sql/managedInstances/azureADOnlyAuthentications",
  "apiVersion": "2022-05-01-preview",
  "name": "[format('{0}/{1}', parameters('managedInstanceName'), 'Default')]",
  "properties": {
    "azureADOnlyAuthentication": true
  },
  "dependsOn": [
    "[resourceId('Microsoft.Sql/managedInstances', parameters('managedInstanceName'))]"
  ]
}
```

### Configure with Bicep

To deploy SQL Managed Instances that pass this rule:

- Set the `properties.administrators.azureADOnlyAuthentication` property to `true`.

For example:

```bicep
resource managedInstance 'Microsoft.Sql/managedInstances@2022-05-01-preview' = {
  name: managedInstanceName
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

Alternatively, you can configure the `Microsoft.Sql/managedInstances/azureADOnlyAuthentications` sub-resource.
To deploy `Microsoft.Sql/managedInstances/azureADOnlyAuthentications` sub-resources that pass this rule:

- Set the `properties.azureADOnlyAuthentication` property to `true`.

For example:

```bicep
resource aadOnly 'Microsoft.Sql/managedInstances/azureADOnlyAuthentications@2022-05-01-preview' = {
  name: 'Default'
  parent: managedInstance
  properties: {
    azureADOnlyAuthentication: true
  }
}
```

## NOTES

The Azure AD admin must be set before enabling Azure AD-only authentication. Managed identity is required to allow support for Azure AD authentication in SQL Managed Instance.

## LINKS

- [Use modern password protection](https://learn.microsoft.com/azure/architecture/framework/security/design-identity-authentication#use-modern-password-protection)
- [Azure AD-only authentication with Azure SQL Managed Instance](https://learn.microsoft.com/azure/azure-sql/database/authentication-azure-ad-only-authentication)
- [Configure and manage Azure AD authentication with Azure SQL Managed Instance](https://learn.microsoft.com/azure/azure-sql/database/authentication-aad-configure)
- [Azure Policy for Azure AD-only authentication with Azure SQL Managed Instance](https://learn.microsoft.com/azure/azure-sql/database/authentication-azure-ad-only-authentication-policy)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/managedinstances#managedinstanceexternaladministrator)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/managedinstances/azureadonlyauthentications#managedinstanceazureadonlyauthproperties)
