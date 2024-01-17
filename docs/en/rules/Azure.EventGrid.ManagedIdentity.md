---
reviewed: 2024-01-17
severity: Important
pillar: Security
category: SE:05 Identity and access management
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

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

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

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [Assign a managed identity to an Event Grid custom topic or domain](https://learn.microsoft.com/azure/event-grid/enable-identity-custom-topics-domains)
- [Authenticate event delivery to event handlers](https://learn.microsoft.com/azure/event-grid/security-authentication)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.eventgrid/topics)
