---
severity: Important
pillar: Reliability
category: Design
resource: Azure Cache for Redis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Redis.AvailabilityZone/
---

# Redis cache should use Availability zones in supported regions

## SYNOPSIS

Premium Redis cache should be deployed with availability zones for high availability.

## DESCRIPTION

Redis Cache using availability zones improve reliability and ensure availability during failure scenarios affecting a data center within a region.
Nodes in one availability zone are physically separated from nodes defined in another availability zone.
By spreading node pools across multiple zones, nodes in one node pool will continue running even if another zone has gone down.

## RECOMMENDATION

Consider using availability zones for Premium Redis Cache deployed in supported regions.

## NOTES

This rule applies when analyzing resources deployed to Azure using *pre-flight* and *in-flight* data.

This rule fails when `"zones"` is `null`, `[]` or less than two zones are used when there are availability zones for the given region. 

This rule fails when cache is not zone redundant(1, 2 and 3) when there are availability zones for the given region.

Configure `AZURE_REDISCACHE_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST` to set additional availability zones that need to be supported which are not in the existing [providers](https://github.com/Azure/PSRule.Rules.Azure/blob/main/data/providers/) for namespace `Microsoft.Cache` and resource type `Redis`.

```yaml
# YAML: The default AZURE_REDISCACHE_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST configuration option
configuration:
  AZURE_REDISCACHE_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST: []
```

## EXAMPLES

### Configure with Azure template

To set availability zones for Premium SKU Redis Cache:

- Set `zones` to a minimum of two zones from `["1", "2", "3"]`.
- Set `Properties.replicasPerMaster` to number of zones - 1, to ensure you have at least as many nodes as zones you are replicating to.
- Set `Properties.sku.name` to `Premium`.
- Set `Properties.sku.family` to `P`. 
- Set `Properties.sku.capacity` to one of `[1, 2, 3, 4, 5]`, depending on the SKU you picked:
  - `P1` - 6 GB
  - `P2` - 13 GB
  - `P3` - 26 GB
  - `P4` - 53 GB
  - `P5` - 120 GB

For example:

```json
{
    "name": "testrediscache",
    "type": "Microsoft.Cache/redis",
    "apiVersion": "2021-06-01",
    "location": "australiaeast",
    "dependsOn": [],
    "properties": {
        "sku": {
            "name": "Premium",
            "family": "P",
            "capacity": 1
        },
        "redisConfiguration": {},
        "enableNonSslPort": false,
        "redisVersion": "4",
        "replicasPerMaster": 2
    },
    "zones": [
        "1",
        "2",
        "3"
    ],
    "tags": {}
}
```

### Configure with Bicep

To set availability zones for Premium SKU Redis Cache:

- Set `zones` to a minimum of two zones from `["1", "2", "3"]`.
- Set `Properties.replicasPerMaster` to number of zones - 1, to ensure you have at least as many nodes as zones you are replicating to.
- Set `Properties.sku.name` to `Premium`.
- Set `Properties.sku.family` to `P`. 
- Set `Properties.sku.capacity` to one of `[1, 2, 3, 4, 5]`, depending on the SKU you picked:
  - `P1` - 6 GB
  - `P2` - 13 GB
  - `P3` - 26 GB
  - `P4` - 53 GB
  - `P5` - 120 GB

For example:

```bicep
resource testrediscache 'Microsoft.Cache/redis@2021-06-01' = {
  name: 'testrediscache'
  location: 'australiaeast'
  properties: {
    sku: {
      name: 'Premium'
      family: 'P'
      capacity: 1
    }
    redisConfiguration: {}
    enableNonSslPort: false
    redisVersion: '4'
    replicasPerMaster: 2
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  tags: {}
  dependsOn: []
}
```

## LINKS

- [Use zone-aware services](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-best-practices#use-zone-aware-services)
- [Enable zone redundancy for Azure Cache for Redis](https://docs.microsoft.com/azure/azure-cache-for-redis/cache-how-to-zone-redundancy)
- [High availability for Azure Cache for Redis](https://docs.microsoft.com/azure/azure-cache-for-redis/cache-high-availability)
- [Azure Template reference](https://docs.microsoft.com/azure/templates/microsoft.cache/2018-03-01/redis?tabs=json)
