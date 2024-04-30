---
reviewed: 2024-05-01
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: SignalR Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SignalR.SLA/
---

# Use an SLA for SignalR Services

## SYNOPSIS

Use SKUs that include an SLA when configuring SignalR Services.

## DESCRIPTION

When choosing a SKU for a SignalR Service you should consider the SLA that is included in the SKU.
SignalR Services offer a range of SKU offerings:

- `Free` - Are designed for early non-production use and do not include any SLA.
- `Standard` - Are designed for production use and include an SLA.
- `Premium` - Are designed for production use and include an SLA.
  Additional, Premium SKUs support increased resilience with Availability Zones.

## RECOMMENDATION

Consider using a Standard or Premium SKU that includes an SLA.

## EXAMPLES

### Configure with Azure template

To deploy services that pass this rule:

- Set the `sku.name` property to `Standard_S1` or `Premium_P1`.

For example:

```json
{
  "type": "Microsoft.SignalRService/signalR",
  "apiVersion": "2023-02-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "kind": "SignalR",
  "sku": {
    "name": "Standard_S1"
  },
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "disableLocalAuth": true,
    "features": [
      {
        "flag": "ServiceMode",
        "value": "Serverless"
      }
    ]
  }
}
```

### Configure with Bicep

To deploy services that pass this rule:

- Set the `sku.name` property to `Standard_S1` or `Premium_P1`.

For example:

```bicep
resource service 'Microsoft.SignalRService/signalR@2023-02-01' = {
  name: name
  location: location
  kind: 'SignalR'
  sku: {
    name: 'Standard_S1'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    disableLocalAuth: true
    features: [
      {
        flag: 'ServiceMode'
        value: 'Serverless'
      }
    ]
  }
}
```

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Azure SignalR Service pricing](https://azure.microsoft.com/pricing/details/signalr-service/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.signalrservice/signalr)
