---
reviewed: 2025-11-10
severity: Important
pillar: Reliability
category: RE:05 Redundancy
resource: Cosmos DB
resourceType: Microsoft.DocumentDB/mongoClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.MongoAvailabilityZone/
---

# Use zone redundant Cosmos DB MongoDB vCore clusters

## SYNOPSIS

Use zone redundant Cosmos DB vCore clusters in supported regions to improve reliability.

## DESCRIPTION

Azure Cosmos DB for MongoDB vCore clusters support zone redundancy.
When zone redundancy is enabled, your data is replicated across multiple zones within an Azure region.

Availability zones are unique physical locations within an Azure region.
Each zone is made up of one or more datacenters equipped with independent power, cooling, and networking infrastructure.
This physical separation ensures that if one zone experiences an outage,
your Cosmos DB cluster continues to serve read and write requests from replicas in other zones without downtime.

With zone redundancy enabled, Azure Cosmos DB provides:

- Automatic failover between zones.
- Continuous availability during zonal failures.
- Enhanced durability by maintaining multiple copies across separate physical locations.
- Protection against datacenter-level disasters while maintaining low-latency access.

Zone redundancy must be configured when you create a Cosmos DB cluster by setting `highAvailability.targetMode` to `ZoneRedundantPreferred`.
This setting cannot be changed after the account is created.
Zone redundancy is only available in regions that support availability zones.

## RECOMMENDATION

Consider using locations configured with zone redundancy to improve workload resiliency of Cosmos DB clusters.

## EXAMPLES

### Configure with Azure template

To deploy MongoDB vCore clusters that pass this rule:

- Set the `properties.highAvailability.targetMode` property to `ZoneRedundantPreferred`.

For example:

```json
{
  "type": "Microsoft.DocumentDB/mongoClusters",
  "apiVersion": "2024-07-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "serverVersion": "8.0",
    "authConfig": {
      "allowedModes": [
        "MicrosoftEntraID"
      ]
    },
    "compute": {
      "tier": "M30"
    },
    "storage": {
      "sizeGb": 128,
      "type": "PremiumSSD"
    },
    "highAvailability": {
      "targetMode": "ZoneRedundantPreferred"
    }
  }
}
```

### Configure with Bicep

To deploy MongoDB vCore clusters that pass this rule:

- Set the `properties.highAvailability.targetMode` property to `ZoneRedundantPreferred`.

For example:

```bicep
resource mongoCluster 'Microsoft.DocumentDB/mongoClusters@2024-07-01' = {
  name: name
  location: location
  properties: {
    serverVersion: '8.0'
    authConfig: {
      allowedModes: [
        'MicrosoftEntraID'
      ]
    }
    compute: {
      tier: 'M30'
    }
    storage: {
      sizeGb: 128
      type: 'PremiumSSD'
    }
    highAvailability: {
      targetMode: 'ZoneRedundantPreferred'
    }
  }
}
```

## LINKS

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [Reliability: Level 1](https://learn.microsoft.com/azure/well-architected/reliability/maturity-model?tabs=level1)
- [Azure regions with availability zone support](https://learn.microsoft.com/azure/reliability/availability-zones-service-support)
- [Architecture strategies for using availability zones and regions](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [High availability in Azure Cosmos DB for MongoDB vCore](https://learn.microsoft.com/azure/cosmos-db/mongodb/vcore/high-availability)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/mongoclusters)
