---
reviewed: 2023-07-09
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Web PubSub Service
resourceType: Microsoft.SignalRService/webPubSub
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.WebPubSub.SLA/
---

# Use an SLA for Web PubSub Services

## SYNOPSIS

Use SKUs that include an SLA when configuring Web PubSub Services.

## DESCRIPTION

When choosing a SKU for a Web PubSub Service you should consider the SLA that is included in the SKU.
Web PubSub Services offer a range of SKU offerings:

- `Free` - Are designed for early non-production use and do not include any SLA.
- `Standard` - Are designed for production use and include an SLA.

## RECOMMENDATION

Consider using a Standard SKU that includes an SLA.

## EXAMPLES

### Configure with Azure template

To deploy services that pass this rule:

- Set the `sku.name` property to `Standard_S1`.

For example:

```json
{
  "type": "Microsoft.SignalRService/webPubSub",
  "apiVersion": "2023-02-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard_S1"
  },
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "disableLocalAuth": true
  }
}
```

### Configure with Bicep

To deploy services that pass this rule:

- Set the `sku.name` property to `Standard_S1`.

For example:

```bicep
resource service 'Microsoft.SignalRService/webPubSub@2023-02-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_S1'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: true
  }
}
```

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Azure Web PubSub pricing](https://azure.microsoft.com/pricing/details/web-pubsub/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.signalrservice/webpubsub)
