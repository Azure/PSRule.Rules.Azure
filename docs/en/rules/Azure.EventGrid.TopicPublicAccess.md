---
reviewed: 2021/11/13
severity: Important
pillar: Security
category: Data flow
resource: Event Grid
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

- Set the `properties.publicNetworkAccess` property to `Disabled`.

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

- [Traffic flow security in Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-network-flow#data-exfiltration)
- [Private Endpoints](https://docs.microsoft.com/azure/event-grid/network-security#private-endpoints)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.eventgrid/topics?tabs=json)
