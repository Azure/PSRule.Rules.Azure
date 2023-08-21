---
severity: Important
pillar: Security
category: Identity and access management
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoor.ManagedIdentity/
---

# Managed identity

## SYNOPSIS

Ensure Front Door uses a managed identity to authorize access to Azure resources.

## DESCRIPTION

When configuring a Standard or Premium SKU with a custom domain using bring your own certificate (BYOC) access to a Key Vault is required.
Standard and Premium Front Door profiles support two methods for authorizing access to Azure resources:

1. Using the Microsoft managed multi-tenant app registration.
   - Standard SKU profiles use the client ID `205478c0-bd83-4e1b-a9d6-db63a3e1e1c8`.
   - Premium SKU profiles use the client ID `d4631ece-daab-479b-be77-ccb713491fc0`.
2. With a system or user assigned managed identity.

The multi-tenant app registration has a number of challenges:

- Only a single client ID is used for each SKU for all Azure Front Door profiles.
  If multiple Front Door profiles are deployed into a single subscription,
  it is not possible to restrict access so that each profile has access to it's own Key Vault.
- A Entra ID (Azure AD) Global Administrator of must register the multi-tenant application for each tenant once before it can be used.

Using an managed identity allows access to Key Vault to be granted using RBAC on an individual basis.

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

Currently Azure Front Door only supports authentication using an Entra ID (Azure AD) to Key Vault.
To use a managed identity, the Standard or Premium SKU is required.
Managed identities are not supported with the Classic SKU.

If you only use Azure Front Door (AFD) managed certificates for custom domains, a managed identity is not required.

## LINKS

- [Use identity-based authentication](https://learn.microsoft.com/azure/architecture/framework/security/design-identity-authentication#use-identity-based-authentication)
- [Managed identities for Azure Front Door](https://learn.microsoft.com/azure/frontdoor/managed-identity)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles#managedserviceidentity)
