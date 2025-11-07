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

Cosmos DB accounts should have availability zones enabled in supported regions.

## DESCRIPTION

Cosmos DB accounts can be configured to use availability zones to provide high availability and resiliency.
When enabled, Azure Cosmos DB automatically replicates data across availability zones in the same region.
This ensures that your data remains available even if an entire availability zone becomes unavailable.

Zone redundancy is configured per location in the `locations` array of the database account.
Each location can have availability zones enabled by setting the `isZoneRedundant` property to `true`.

Availability zones are supported in many Azure regions.
If a region doesn't support availability zones, you should configure geo-replication to another region for resiliency.

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
