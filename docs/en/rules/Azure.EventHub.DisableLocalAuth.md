---
reviewed: 2024-02-24
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Event Hub
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EventHub.DisableLocalAuth/
---

# Use identity-based authentication for Event Hub namespaces

## SYNOPSIS

Authenticate Event Hub publishers and consumers with Entra ID identities.

## DESCRIPTION

To publish or consume events from Event Hubs cryptographic keys, or Entra ID (previously Azure AD) identities can be used.
Cryptographic keys include Shared Access Policy keys or Shared Access Signature (SAS) tokens.
With Entra ID authentication, the identity is validated against Azure AD.
Using Entra ID identities centralizes identity management and auditing.

Once you decide to use Entra ID authentication, you can disable authentication using keys or SAS tokens.

## RECOMMENDATION

Consider only using Entra ID identities to publish or consume events from Event Hub.
Then disable authentication based on access keys or SAS tokens.

## EXAMPLES

### Configure with Azure template

To deploy Event Hub namespaces that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```json
{
  "type": "Microsoft.EventHub/namespaces",
  "apiVersion": "2024-01-01",
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
    "minimumTlsVersion": "1.2",
    "publicNetworkAccess": "Disabled",
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
resource ns 'Microsoft.EventHub/namespaces@2024-01-01' = {
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
    minimumTlsVersion: '1.2'
    publicNetworkAccess: 'Disabled'
    isAutoInflateEnabled: true
    maximumThroughputUnits: 10
    zoneRedundant: true
  }
}
```

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Azure Event Hub namespaces should have local authentication methods disabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Event%20Hub/EventHub_DisableLocalAuth_AuditDeny.json)
- [Configure Azure Event Hub namespaces to disable local authentication](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Event%20Hub/EventHub_DisableLocalAuth_Modify.json)

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access#use-identity-based-authentication)
- [Authorize access to Event Hubs resources using Microsoft Entra ID](https://learn.microsoft.com/azure/event-hubs/authorize-access-azure-active-directory)
- [Disabling Local/SAS Key authentication](https://learn.microsoft.com/azure/event-hubs/authenticate-shared-access-signature#disabling-localsas-key-authentication)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.eventhub/namespaces)
