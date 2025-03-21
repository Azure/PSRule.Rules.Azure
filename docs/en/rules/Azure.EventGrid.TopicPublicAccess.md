---
reviewed: 2024-01-17
severity: Important
pillar: Security
category: SE:06 Network controls
resource: Event Grid
resourceType: Microsoft.EventGrid/topics
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EventGrid.TopicPublicAccess/
---

# Use Event Grid Private Endpoints

## SYNOPSIS

Use Private Endpoints to access Event Grid topics and domains.

## DESCRIPTION

By default, public network access is enabled for an Event Grid topic or domain.
To allow access via private endpoints only, disable public network access.

## RECOMMENDATION

Consider using Private Endpoints to access Event Grid topics and domains.
To limit access to Event Grid topics and domains, disable public access.

## EXAMPLES

### Configure with Azure template

To deploy Event Grid Topics that pass this rule:

- Set the `properties.publicNetworkAccess` property to `Disabled`.

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

- Set the `properties.publicNetworkAccess` property to `Disabled`.

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

<!-- external:avm avm/res/event-grid/topic publicNetworkAccess -->

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Private Endpoints](https://learn.microsoft.com/azure/event-grid/network-security#private-endpoints)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.eventgrid/topics)
