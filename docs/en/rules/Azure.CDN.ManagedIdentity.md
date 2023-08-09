---
severity: Important
pillar: Security
category: Identity and access management
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.CDN.ManagedIdentity/
---

# Managed identity

## SYNOPSIS

Ensure managed identity is used for Azure Front Door to allow support for Azure AD authentication.

## DESCRIPTION

A managed identity is the recommmeded for allowing support for Azure AD authentication in a Azure Front Door instance.

You can enable the instance identity (SMI or UMI) to allow support for Azure AD authentication in Azure Front Door.

Additionally, a managed identity is required in the future, as the Azure Active Directory App solution will be retired for Azure Front Door.

## RECOMMENDATION

Consider configure a managed identity to allow support for Azure AD authentication.

## EXAMPLES

### Configure with Azure template

To deploy Azure Front Door instances that pass this rule:

- Set `identity.type` to `SystemAssigned` or `UserAssigned` or `SystemAssigned,UserAssigned`.
- If `identity.type` is `UserAssigned` or `SystemAssigned,UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

For example:

```json
{
  "type": "Microsoft.Cdn/profiles",
  "apiVersion": "2022-11-01-preview",
  "name": "myFrontDoor",
  "location": "global",
  "sku": {
    "name": "Standard_AzureFrontDoor"
  },
  "identity": {
    "type": "SystemAssigned",
    "userAssignedIdentities": {}
  }
}
```
 
### Configure with Bicep

To deploy Azure Front Door instances that pass this rule:

- Set `identity.type` to `SystemAssigned` or `UserAssigned` or `SystemAssigned,UserAssigned`.
- If `identity.type` is `UserAssigned` or `SystemAssigned,UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

For example:

```bicep
resource frontDoorProfile 'Microsoft.Cdn/profiles@2022-11-01-preview' = {
  name: 'myFrontDoor'
  location: 'global'
  sku: {
    name: 'Standard_AzureFrontDoor'
  }
  identity: {
    type: 'SystemAssigned'
    userAssignedIdentities: {}
  }
}
```

## NOTES

Azure Front Door Standard or Premium SKU is required for managed identity.

## LINKS

- [Use identity-based authentication](https://learn.microsoft.com/azure/architecture/framework/security/design-identity-authentication#use-identity-based-authentication)
- [Managed identities for Azure Front Door](https://learn.microsoft.com/azure/frontdoor/managed-identity)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles#managedserviceidentity)
