---
severity: Important
pillar: Security
category: Authentication
resource: SQL Managed Instance
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQLMI.ManagedIdentity/
---

# Managed identity

## SYNOPSIS

Ensure managed identity is used to allow support for Azure AD authentication.

## DESCRIPTION

A managed identity is required for allowing support for Azure AD authentication in SQL Managed Instance.

You must enable the instance identity (SMI or UMI) to allow support for Azure AD authentication in SQL Managed Instance. 

Additionally, a managed identity is required for transparent data encryption with customer-managed key.

## RECOMMENDATION

Consider configure a managed identity to allow support for Azure AD authentication.

## EXAMPLES

### Configure with Azure template

To deploy SQL Managed Instances that pass this rule:

- Set `identity.type` to `SystemAssigned` or `UserAssigned` or `SystemAssigned,UserAssigned`.
- If `identity.type` is `UserAssigned` or `SystemAssigned,UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

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
  "properties": {}
}
```
 
### Configure with Bicep

To deploy SQL Managed Instances that pass this rule:

- Set `identity.type` to `SystemAssigned` or `UserAssigned` or `SystemAssigned,UserAssigned`.
- If `identity.type` is `UserAssigned` or `SystemAssigned,UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

For example:

```bicep
resource managedInstance 'Microsoft.Sql/managedInstances@2022-05-01-preview' = {
  name: appName
  location: location
  name: managedInstanceName
  location: location
  identity: {
    type: 'SystemAssigned'
    userAssignedIdentities: {}
  }
  properties: {}
}
```

## NOTES

To grant permissions to access Microsoft Graph through an SMI or a UMI, you need to use PowerShell.
You can't grant these permissions by using the Azure portal.

## LINKS

- [Use identity-based authentication](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication#use-identity-based-authentication)
- [Managed identities in Azure AD for Azure SQL Managed Instance](https://learn.microsoft.com/azure/azure-sql/database/authentication-azure-ad-user-assigned-managed-identity)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/managedinstances)
