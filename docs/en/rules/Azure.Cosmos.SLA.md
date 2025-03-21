---
reviewed: 2024-05-01
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Cosmos DB
resourceType: Microsoft.DocumentDB/databaseAccounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.SLA/
---

# Use paid tier for production workloads

## SYNOPSIS

Use a paid tier to qualify for a Service Level Agreement (SLA).

## DESCRIPTION

Cosmos DB offers one account on selected subscriptions to be marked to use a free tier allowance of 1000 DTUs.
This free tier is intended for developers to try Cosmos DB during early development and proof of concepts (PoC).
Using the free tier offer is not intended to be used for production level workloads.

When using the free tier, the SLA for Cosmos DB does not apply.

## RECOMMENDATION

Consider using a paid SKU to qualify for a Service Level Agreement (SLA).

## EXAMPLES

### Configure with Azure template

To deploy Cosmos DB accounts that pass this rule:

- Set the `properties.enableFreeTier` property to `false` or do not configure the property.

For example:

```json
{
  "type": "Microsoft.DocumentDB/databaseAccounts",
  "apiVersion": "2023-04-15",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "enableFreeTier": false,
    "consistencyPolicy": {
      "defaultConsistencyLevel": "Session"
    },
    "databaseAccountOfferType": "Standard",
    "locations": [
      {
        "locationName": "[parameters('location')]",
        "failoverPriority": 0,
        "isZoneRedundant": true
      }
    ],
    "disableKeyBasedMetadataWriteAccess": true
  }
}
```

### Configure with Bicep

To deploy Cosmos DB accounts that pass this rule:

- Set the `properties.enableFreeTier` property to `false` or do not configure the property.

For example:

```bicep
resource account 'Microsoft.DocumentDB/databaseAccounts@2023-04-15' = {
  name: name
  location: location
  properties: {
    enableFreeTier: false
    consistencyPolicy: {
      defaultConsistencyLevel: 'Session'
    }
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: location
        failoverPriority: 0
        isZoneRedundant: true
      }
    ]
    disableKeyBasedMetadataWriteAccess: true
  }
}
```

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Try Azure Cosmos DB free](https://learn.microsoft.com/azure/cosmos-db/try-free)
- [Azure Cosmos DB pricing](https://azure.microsoft.com/pricing/details/cosmos-db/autoscale-provisioned/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/databaseaccounts)
