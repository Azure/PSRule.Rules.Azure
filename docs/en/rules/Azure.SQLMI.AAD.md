---
severity: Critical
pillar: Security
category: Authentication
resource: SQL Managed Instance
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQLMI.AAD/
---

# Use AAD authentication with SQL Managed Instances

## SYNOPSIS

Use Azure Active Directory (AAD) authentication with Azure SQL Managed Instances.

## DESCRIPTION

Azure SQL Managed Instance offer two authentication models, Azure Active Directory (AAD) and SQL logins.
AAD authentication supports centialized identity management in addition to modern password protections.
Some of the benefits of AAD authentication over SQL authentication including:

- Support for Azure Multi-Factor Authentication (MFA).
- Conditional-based access with Conditional Access.

Using AAD authentication requires an Active Directory administrator provisioned, if a instance does not have an Azure Active Directory administrator, then Azure Active Directory logins and users receive a `Cannot connect` to instance error.

It is also possible to disable SQL authentication entirely by enabling Azure AD-only authentication.

## RECOMMENDATION

Consider using Azure Active Directory (AAD) authentication with SQL Managed Instances.
Additionally, consider disabling SQL authentication.

## EXAMPLES

An Active Directory administrator can be provisioned in two different ways.

### Configure with Azure template

To deploy SQL Managed Instances that pass this rule:

- Set the `properties.administrators.administratorType` to `ActiveDirectory`.
- Set the `properties.administrators.login` to the administrator login object name.
- Set the `properties.administrators.sid` to the object ID GUID of the administrator user, group, or application.

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

### Configure with Bicep

To deploy SQL Managed Instances that pass this rule:

- Set the `properties.administrators.administratorType` to `ActiveDirectory`.
- Set the `properties.administrators.login` to the administrator login object name.
- Set the `properties.administrators.sid` to the object ID GUID of the administrator user, group, or application.

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

### Configure with Azure template

To deploy SQL Managed Instances that pass this rule:

- Configure an `Microsoft.Sql/managedInstances/administrators` sub-resource.
- Set the `properties.administratorType` to `ActiveDirectory`.
- Set the `properties.login` to the administrator login object name.
- Set the `properties.sid` to the object ID GUID of the administrator user, group, or application.

For example:

```json
{
  "type": "Microsoft.Sql/managedInstances/administrators",
  "apiVersion": "2022-05-01-preview",
  "name":  "[format('{0}/{1}', parameters('managedInstanceName'), 'ActiveDirectory')]",
  "properties": {
      "administratorType": "ActiveDirectory",
      "login": "[parameters('login')]",
      "sid": "[parameters('sid')]"
  }
}
```

### Configure with Bicep

To deploy SQL Managed Instances that pass this rule:

- Configure an `Microsoft.Sql/managedInstances/administrators` sub-resource.
- Set the `properties.administratorType` to `ActiveDirectory`.
- Set the `properties.login` to the administrator login object name.
- Set the `properties.sid` to the object ID GUID of the administrator user, group, or application.

For example:

```bicep
resource sqlAdministrator 'Microsoft.Sql/managedInstances//administrators@2022-05-01-preview' = {
  parent: managedInstance
  name: 'ActiveDirectory'
  properties: {
    administratorType: 'ActiveDirectory'
    login: login
    sid: sid
  }
}
```

## NOTES

If both the `properties.administrators` property and `Microsoft.Sql/managedInstances/administrators` are set,
the sub-resoure will override the property.

Managed identity is required to allow support for Azure AD authentication in SQL Managed Instance.

## LINKS

- [Use modern password protection](https://learn.microsoft.com/azure/architecture/framework/security/design-identity-authentication#use-modern-password-protection)
- [Configure and manage Azure AD authentication with Azure SQL](https://docs.microsoft.com/azure/azure-sql/database/authentication-aad-configure)
- [Using multi-factor Azure Active Directory authentication](https://docs.microsoft.com/azure/azure-sql/database/authentication-mfa-ssms-overview)
- [Conditional Access with Azure SQL Database and Azure Synapse Analytics](https://docs.microsoft.com/azure/azure-sql/database/conditional-access-configure)
- [Azure AD-only authentication with Azure SQL](https://docs.microsoft.com/azure/azure-sql/database/authentication-azure-ad-only-authentication)
- [Azure Policy for Azure Active Directory only authentication with Azure SQL](https://docs.microsoft.com/azure/azure-sql/database/authentication-azure-ad-only-authentication-policy)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.sql/servers/administrators)
