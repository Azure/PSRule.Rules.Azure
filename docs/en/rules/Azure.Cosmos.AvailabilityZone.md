---
reviewed: 2025-11-07
severity: Important
pillar: Reliability
category: RE:05 Redundancy
resource: Cosmos DB
resourceType: Microsoft.DocumentDB/databaseAccounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.AvailabilityZone/
---

# Use zone redundant Cosmos DB accounts

## SYNOPSIS

Use zone redundant Cosmos DB accounts in supported regions to improve reliability.

## DESCRIPTION

Azure Cosmos DB accounts deployed with the request units (RU) deployment model support zone redundancy.
When zone redundancy is enabled, your data is replicated across multiple zones within an Azure region.

Availability zones are unique physical locations within an Azure region.
Each zone is made up of one or more datacenters equipped with independent power, cooling, and networking infrastructure.
This physical separation ensures that if one zone experiences an outage,
your Cosmos DB account continues to serve read and write requests from replicas in other zones without downtime.

With zone redundancy enabled, Azure Cosmos DB provides:

- Automatic failover between zones.
- Continuous availability during zonal failures.
- Enhanced durability by maintaining multiple copies across separate physical locations.
- Protection against datacenter-level disasters while maintaining low-latency access.

Zone redundancy must be configured when you create a Cosmos DB account by setting `isZoneRedundant` to `true` for each location.
This setting cannot be changed after the account is created.
Zone redundancy is only available in regions that support availability zones.

## RECOMMENDATION

Consider using locations configured with zone redundancy to improve workload resiliency of Cosmos DB accounts.

## EXAMPLES

### Configure with Azure template

To deploy database accounts that pass this rule:

- Set the `properties.locations[*].isZoneRedundant` property to `true` for each location.

For example:

```json
{
  "type": "Microsoft.DocumentDB/databaseAccounts",
  "apiVersion": "2024-11-15",
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
    "disableKeyBasedMetadataWriteAccess": true,
    "minimalTlsVersion": "Tls12"
  }
}
```

### Configure with Bicep

To deploy database accounts that pass this rule:

- Set the `properties.locations[*].isZoneRedundant` property to `true` for each location.

For example:

```bicep
resource account 'Microsoft.DocumentDB/databaseAccounts@2024-11-15' = {
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
    minimalTlsVersion: 'Tls12'
  }
}
```

## NOTES

This rule applies to Cosmos DB accounts deployed with the request units (RU) deployment model.

## LINKS

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [Reliability: Level 1](https://learn.microsoft.com/azure/well-architected/reliability/maturity-model?tabs=level1)
- [Architecture strategies for using availability zones and regions](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Azure regions with availability zone support](https://learn.microsoft.com/azure/reliability/availability-zones-service-support)
- [High availability with Azure Cosmos DB](https://learn.microsoft.com/azure/reliability/reliability-cosmos-db-nosql)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/databaseaccounts)
