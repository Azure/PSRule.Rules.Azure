---
reviewed: 2022-01-22
severity: Important
pillar: Security
category: Authentication
resource: Event Hub
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EventHub.DisableLocalAuth/
---

# Use identity-based authentication for Event Hub namespaces

## SYNOPSIS

Authenticate Event Hub publishers and consumers with Azure AD identities.

## DESCRIPTION

To publish or consume events from Event Hubs cryptographic keys, or Azure AD identities can be used.
Cryptographic keys include Shared Access Policy keys or Shared Access Signature (SAS) tokens.
With Azure AD authentication, the identity is validated against Azure AD.
Using Azure AD identities centralizes identity management and auditing.

Once you decide to use Azure AD authentication, you can disable authentication using keys or SAS tokens.

## RECOMMENDATION

Consider only using Azure AD identities to publish or consume events from Event Hub.
Then disable authentication based on access keys or SAS tokens.

## EXAMPLES

### Configure with Azure template

To deploy Event Hub namespaces that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```json
{
    "type": "Microsoft.EventHub/namespaces",
    "apiVersion": "2021-11-01",
    "name": "[parameters('name')]",
    "location": "[parameters('location')]",
    "identity": {
        "type": "SystemAssigned"
    },
    "sku": {
        "name": "Standard"
    },
    "properties": {
        "disableLocalAuth": true,
        "isAutoInflateEnabled": true,
        "maximumThroughputUnits": 10,
        "zoneRedundant": true
    }
}
```

### Configure with Bicep

To deploy Event Hub namespaces that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```bicep
resource ns 'Microsoft.EventHub/namespaces@2021-11-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Standard'
  }
  properties: {
    disableLocalAuth: true
    isAutoInflateEnabled: true
    maximumThroughputUnits: 10
    zoneRedundant: true
  }
}
```

## LINKS

- [Use identity-based authentication](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication#use-identity-based-authentication)
- [Authorize access to Event Hubs resources using Azure Active Directory](https://docs.microsoft.com/azure/event-hubs/authorize-access-azure-active-directory)
- [Disabling Local/SAS Key authentication](https://docs.microsoft.com/azure/event-hubs/authenticate-shared-access-signature#disabling-localsas-key-authentication)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.eventhub/namespaces)
