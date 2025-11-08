---
reviewed: 2025-11-07
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: Cosmos DB
resourceType: Microsoft.DocumentDB/databaseAccounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.AvailabilityZone/
---

# Use zone redundant Cosmos DB accounts

## SYNOPSIS

Use zone redundant Cosmos DB accounts in supported regions to improve reliability.

## DESCRIPTION

Azure Cosmos DB supports zone redundancy to provide high availability and protect your data from datacenter-level failures within a region.
When zone redundancy is enabled, Azure Cosmos DB automatically distributes replicas of your data across multiple availability zones.

Availability zones are unique physical locations within an Azure region.
Each zone is made up of one or more datacenters equipped with independent power, cooling, and networking infrastructure.
This physical separation ensures that if one zone experiences an outage, your Cosmos DB account continues to serve read and write requests from replicas in other zones without downtime.

With zone redundancy enabled, Azure Cosmos DB provides:

- Automatic failover between zones with no data loss.
- Continuous availability during zone failures.
- Enhanced durability by maintaining multiple copies across separate physical locations.
- Protection against datacenter-level disasters while maintaining low-latency access.

Zone redundancy must be configured when you create a Cosmos DB account by setting `isZoneRedundant` to `true` for each location.
This setting cannot be changed after the account is created.
Zone redundancy is only available in regions that support availability zones.

## EXAMPLES

### Configure with Azure template

To deploy database accounts that pass this rule:

- Set the `properties.locations[*].isZoneRedundant` property to `true` for each location.

For example:

```json
{
  "type": "Microsoft.DocumentDB/databaseAccounts",
  "apiVersion": "2023-11-15",
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
resource account 'Microsoft.DocumentDB/databaseAccounts@2023-11-15' = {
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

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [High availability with Azure Cosmos DB](https://learn.microsoft.com/azure/cosmos-db/high-availability)
- [What are availability zones?](https://learn.microsoft.com/azure/reliability/availability-zones-overview)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/databaseaccounts)
