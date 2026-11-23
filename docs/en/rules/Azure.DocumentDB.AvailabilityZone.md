---
reviewed: 2026-11-23
severity: Important
pillar: Reliability
category: RE:05 Redundancy
resource: Azure DocumentDB
resourceType: Microsoft.DocumentDB/mongoClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.DocumentDB.AvailabilityZone/
---

# Use zone redundant Azure DocumentDB clusters

## SYNOPSIS

Use zone redundant Azure DocumentDB clusters in supported regions to improve reliability.

## DESCRIPTION

Azure DocumentDB clusters support zone redundant high availability.
When zone redundancy is enabled, primary and standby shards synchronously replicate data across availability zones within an Azure region.

Availability zones are unique physical locations within an Azure region.
Each zone is made up of one or more datacenters equipped with independent power, cooling, and networking infrastructure.
This physical separation ensures that if one zone experiences an outage,
Azure DocumentDB can fail over to standby shards in another zone without data loss.
Applications might observe write slowness while the service retries operations during failover.

With zone redundancy enabled, Azure DocumentDB provides:

- Automatic failover between zones.
- Continuous availability during zonal failures.
- Enhanced durability by maintaining multiple copies across separate physical locations.
- Protection against datacenter-level disasters while maintaining low-latency access.

Configure high availability by setting `properties.highAvailability.targetMode` to `ZoneRedundantPreferred`.
High availability can be enabled or disabled when creating a cluster or on an existing cluster without database downtime.
The service prefers cross-zone deployment when availability zones are available and otherwise falls back to same-zone high availability.

## RECOMMENDATION

Consider configuring zone redundant high availability in locations that support availability zones to improve reliability.

## EXAMPLES

### Configure with Azure template

To deploy Azure DocumentDB clusters that pass this rule:

- Set the `properties.highAvailability.targetMode` property to `ZoneRedundantPreferred`.

For example:

```json
{
  "type": "Microsoft.DocumentDB/mongoClusters",
  "apiVersion": "2025-09-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "administrator": {
      "userName": "[parameters('administratorUserName')]",
      "password": "[parameters('administratorPassword')]"
    },
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
    "sharding": {
      "shardCount": 1
    },
    "highAvailability": {
      "targetMode": "ZoneRedundantPreferred"
    }
  }
}
```

### Configure with Bicep

To deploy Azure DocumentDB clusters that pass this rule:

- Set the `properties.highAvailability.targetMode` property to `ZoneRedundantPreferred`.

For example:

```bicep
@secure()
param administratorPassword string
param administratorUserName string
param name string
param location string = resourceGroup().location

resource cluster 'Microsoft.DocumentDB/mongoClusters@2025-09-01' = {
  name: name
  location: location
  properties: {
    administrator: {
      userName: administratorUserName
      password: administratorPassword
    }
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
    sharding: {
      shardCount: 1
    }
    highAvailability: {
      targetMode: 'ZoneRedundantPreferred'
    }
  }
}
```

## NOTES

This rule applies to Azure DocumentDB, formerly Azure Cosmos DB for MongoDB vCore.
The resource type remains `Microsoft.DocumentDB/mongoClusters`.
The previous rule name, `Azure.Cosmos.MongoAvailabilityZone`, remains a compatibility alias.

This rule passes without requiring zone redundancy in regions that do not support availability zones.
Same-zone high availability does not protect against an availability zone outage.

For initial deployment, include `NativeAuth` in `properties.authConfig.allowedModes`.
Declare `administratorPassword` as a `secureString` parameter in the Azure template.

## LINKS

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [Azure regions with availability zone support](https://learn.microsoft.com/azure/reliability/availability-zones-service-support)
- [Reliability: Level 1](https://learn.microsoft.com/azure/well-architected/reliability/maturity-model?tabs=level1)
- [Architecture strategies for using availability zones and regions](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [High availability in Azure DocumentDB](https://learn.microsoft.com/azure/documentdb/high-availability)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/mongoclusters)
