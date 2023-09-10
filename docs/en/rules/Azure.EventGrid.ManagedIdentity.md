---
reviewed: 2022-05-14
severity: Important
pillar: Security
category: Authentication
resource: Event Grid
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EventGrid.ManagedIdentity/
---

# Use Managed Identity for Event Grid Topics

## SYNOPSIS

Use managed identities to deliver Event Grid Topic events.

## DESCRIPTION

When delivering events you can use Managed Identities to authenticate event delivery.
You can enable either system-assigned identity or user-assigned identity but not both.
You can have at most two user-assigned identities assigned to a topic or domain.

## RECOMMENDATION

Consider configuring a managed identity for each Event Grid Topic.

## EXAMPLES

### Configure with Azure template

To deploy Event Grid Topics that pass this rule:

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

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

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

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
- [Assign a managed identity to an Event Grid custom topic or domain](https://docs.microsoft.com/azure/event-grid/enable-identity-custom-topics-domains)
- [Authenticate event delivery to event handlers](https://docs.microsoft.com/azure/event-grid/security-authentication)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.eventgrid/topics)
