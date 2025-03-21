---
severity: Critical
pillar: Security
category: Authentication
resource: SQL Managed Instance
resourceType: Microsoft.Sql/managedInstances
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQLMI.AAD/
---

# Use AAD authentication with SQL Managed Instance

## SYNOPSIS

Use Azure Active Directory (AAD) authentication with Azure SQL Managed Instance.

## DESCRIPTION

Azure SQL Managed Instance supports authentication with SQL logins and Azure AD authentication.

By default, authentication with SQL logins is enabled.
SQL logins are unable to provide sufficient protection for identities.
Azure AD authentication provides strong protection controls including conditional access, identity governance, and privileged identity management.

- Support for Azure Multi-Factor Authentication (MFA).
- Conditional-based access with Conditional Access.

Using Azure AD authentication requires an Azure AD administrator provisioned, if a instance does not have an Azure AD administrator, then Azure AD logins and users receive a `Cannot connect` to instance error.

Once you decide to use Azure AD authentication, you can disable authentication with SQL logins.

## RECOMMENDATION

Consider using Azure Active Directory (AAD) authentication with SQL Managed Instance.
Additionally, consider disabling SQL authentication.

## EXAMPLES

An Azure AD administrator can be provisioned in two different ways.

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

Alternatively, you can configure the `Microsoft.Sql/managedInstances/administrators` sub-resource.
To deploy `Microsoft.Sql/managedInstances/administrators` sub-resources that pass this rule:

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
  },
  "dependsOn": [
    "[resourceId('Microsoft.Sql/managedInstances', parameters('managedInstanceName'))]"
  ]
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

Alternatively, you can configure the `Microsoft.Sql/managedInstances/administrators` sub-resource.
To deploy `Microsoft.Sql/managedInstances/administrators` sub-resources that pass this rule:

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
- [Use Azure AD authentication](https://learn.microsoft.com/azure/azure-sql/database/authentication-aad-overview)
- [Configure and manage Azure AD authentication](https://learn.microsoft.com/azure/azure-sql/database/authentication-aad-configure)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/managedinstances#managedinstanceexternaladministrator)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/managedinstances/administrators#managedinstanceadministratorproperties)
