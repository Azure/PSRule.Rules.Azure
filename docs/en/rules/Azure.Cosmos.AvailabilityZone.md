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

Azure Cosmos DB supports zone redundancy to provide high availability and protect your data from datacenter failures.
When zone redundancy is enabled for a location, Azure Cosmos DB automatically distributes replicas across multiple availability zones within that region.

Availability zones are physically separate datacenters within an Azure region.
Each zone has independent power, cooling, and networking infrastructure.
By distributing data across zones, your Cosmos DB account can tolerate zone failures while maintaining availability for read and write operations.

Zone redundancy must be configured when you create a Cosmos DB account by setting `isZoneRedundant` to `true` for each location.
This setting cannot be changed after the account is created.
Note that zone redundancy is only available in regions that support availability zones and may incur additional costs.

For regions that don't support availability zones, consider using geo-replication to ensure business continuity and disaster recovery.

## RECOMMENDATION

Consider using availability zones for Cosmos DB accounts to improve reliability and ensure high availability of your data.

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
