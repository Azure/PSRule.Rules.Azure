---
reviewed: 2024-01-17
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Event Grid
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EventGrid.DisableLocalAuth/
---

# Use identity-based authentication for Event Grid topics

## SYNOPSIS

Authenticate publishing clients with Azure AD identities.

## DESCRIPTION

To publish events to Event Grid access keys, SAS tokens, or Azure AD identities can be used.
With Azure AD authentication, the identity is validated against the Microsoft Identity Platform.
Using Azure AD identities centralizes identity management and auditing.

Once you decide to use Azure AD authentication, you can disable authentication using keys or SAS tokens.

## RECOMMENDATION

Consider only using Azure AD identities to publish events to Event Grid.
Then disable authentication based on access keys or SAS tokens.

## EXAMPLES

### Configure with Azure template

To deploy Event Grid Topics that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```json
{
  "type": "Microsoft.EventGrid/topics",
  "apiVersion": "2022-06-15",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "disableLocalAuth": true,
    "publicNetworkAccess": "Disabled",
    "inputSchema": "CloudEventSchemaV1_0"
  }
}
```

### Configure with Bicep

To deploy Event Grid Topics that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```bicep
resource eventGrid 'Microsoft.EventGrid/topics@2022-06-15' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: true
    publicNetworkAccess: 'Disabled'
    inputSchema: 'CloudEventSchemaV1_0'
  }
}
```

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Azure Event Grid topics should have local authentication methods disabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Event%20Grid/Topics_DisableLocalAuth_AuditDeny.json)
- [Configure Azure Event Grid topics to disable local authentication](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Event%20Grid/Topics_DisableLocalAuth_Modify.json)

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/event-grid-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Authentication and authorization with Microsoft Entra ID](https://learn.microsoft.com/azure/event-grid/authenticate-with-microsoft-entra-id)
- [Disable key and shared access signature authentication](https://learn.microsoft.com/azure/event-grid/authenticate-with-microsoft-entra-id#disable-key-and-shared-access-signature-authentication)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.eventgrid/topics)
