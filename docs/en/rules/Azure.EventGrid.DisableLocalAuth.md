---
reviewed: 2022-09-09
severity: Important
pillar: Security
category: Authentication
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
    "apiVersion": "2021-06-01-preview",
    "name": "[parameters('topicName')]",
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
resource eventGrid 'Microsoft.EventGrid/topics@2021-06-01-preview' = {
  name: topicName
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

## LINKS

- [Use identity-based authentication](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication#use-identity-based-authentication)
- [IM-1: Use centralized identity and authentication system](https://docs.microsoft.com/security/benchmark/azure/security-controls-v3-identity-management#im-1-use-centralized-identity-and-authentication-system)
- [Authentication and authorization with Azure Active Directory](https://docs.microsoft.com/azure/event-grid/authenticate-with-active-directory)
- [Disable key and shared access signature authentication](https://docs.microsoft.com/azure/event-grid/authenticate-with-active-directory#disable-key-and-shared-access-signature-authentication)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.eventgrid/topics)
