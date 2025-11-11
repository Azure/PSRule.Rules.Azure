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

Azure Cosmos DB for MongoDB vCore clusters support high availability configuration with availability zones to provide resilience and business continuity.

Availability zones are physically separate locations within an Azure region.
Each zone is composed of one or more datacenters equipped with independent power, cooling, and networking.
Using availability zones helps protect your MongoDB vCore cluster from datacenter-level failures.

MongoDB vCore clusters support the following high availability modes:

- **Disabled** - No high availability is configured.
- **SameZone** - High availability within a single zone.
- **ZoneRedundantPreferred** - Zone-redundant high availability across multiple availability zones.

This rule checks that MongoDB vCore clusters deployed to regions that support availability zones have zone-redundant high availability enabled.
Using `ZoneRedundantPreferred` mode ensures that your MongoDB vCore cluster is resilient to zone-level failures,
providing better availability and durability for your data.

## RECOMMENDATION

Consider configuring Azure Cosmos DB for MongoDB vCore clusters deployed to supported regions to use zone-redundant high availability by setting the high availability mode to `ZoneRedundantPreferred`.

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
- [Azure regions with availability zone support](https://learn.microsoft.com/azure/reliability/availability-zones-service-support)
- [Architecture strategies for using availability zones and regions](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Reliability: Level 1](https://learn.microsoft.com/azure/well-architected/reliability/maturity-model?tabs=level1)
- [High availability in Azure Cosmos DB for MongoDB vCore](https://learn.microsoft.com/azure/cosmos-db/mongodb/vcore/high-availability)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/mongoclusters)
