---
reviewed: 2025-11-10
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: Cosmos DB
resourceType: Microsoft.DocumentDB/mongoClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cosmos.MongoDBvCoreAvailabilityZone/
---

# Use zone-redundant high availability for MongoDB vCore clusters

## SYNOPSIS

Azure Cosmos DB for MongoDB vCore clusters should use zone-redundant high availability.

## DESCRIPTION

Azure Cosmos DB for MongoDB vCore clusters support high availability configuration with availability zones to provide resilience and business continuity.

Availability zones are physically separate locations within an Azure region.
Each zone is composed of one or more datacenters equipped with independent power, cooling, and networking.
Using availability zones helps protect your MongoDB vCore cluster from datacenter-level failures.

MongoDB vCore clusters support the following high availability modes:

- **Disabled** - No high availability is configured.
- **SameZone** - High availability within a single zone.
- **ZoneRedundantPreferred** - Zone-redundant high availability across multiple availability zones.

Using `ZoneRedundantPreferred` mode ensures that your MongoDB vCore cluster is resilient to zone-level failures,
providing better availability and durability for your data.

## RECOMMENDATION

Consider configuring Azure Cosmos DB for MongoDB vCore clusters to use zone-redundant high availability by setting the high availability mode to `ZoneRedundantPreferred`.

## EXAMPLES

### Configure with Azure template

To deploy MongoDB vCore clusters that pass this rule:

- Set the `properties.highAvailability.targetMode` property to `ZoneRedundantPreferred`.

For example:

```json
{
  "type": "Microsoft.DocumentDB/mongoClusters",
  "apiVersion": "2025-04-01-preview",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "serverVersion": "8.0",
    "authConfig": {
      "allowedModes": [
        "NativeAuth",
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
resource mongoCluster 'Microsoft.DocumentDB/mongoClusters@2025-04-01-preview' = {
  name: name
  location: location
  properties: {
    serverVersion: '8.0'
    authConfig: {
      allowedModes: [
        'NativeAuth'
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

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Reliability: Level 1](https://learn.microsoft.com/azure/well-architected/reliability/maturity-model?tabs=level1)
- [High availability in Azure Cosmos DB for MongoDB vCore](https://learn.microsoft.com/azure/cosmos-db/mongodb/vcore/high-availability)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/mongoclusters)
