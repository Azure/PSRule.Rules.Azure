---
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: Azure Cache for Redis Enterprise
resourceType: Microsoft.Cache/redisEnterprise
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.RedisEnterprise.Zones/
---

# Enterprise Redis cache should use Availability zones in supported regions

## SYNOPSIS

Enterprise Redis cache should be zone-redundant for high availability.

## DESCRIPTION

Redis Cache using availability zones improve reliability and ensure availability during failure scenarios affecting a data center within a region.
Nodes in one availability zone are physically separated from nodes defined in another availability zone.
By spreading node pools across multiple zones, nodes in one node pool will continue running even if another zone has gone down.

## RECOMMENDATION

Consider using availability zones for Enterprise Redis Cache deployed in supported regions.

## EXAMPLES

### Configure with Azure template

To set availability zones for Enterprise SKU Redis Cache:

- Set `zones` to `["1", "2", "3"]` or zone-redundancy.
- Set `Properties.sku.name` to one of:
  - `Enterprise_E10` - 12 GB
  - `Enterprise_E20` - 25 GB
  - `Enterprise_E50` - 50 GB
  - `Enterprise_E100` - 100 GB
  - `EnterpriseFlash_F300` - 345 GB
  - `EnterpriseFlash_F700` - 715 GB
  - `EnterpriseFlash_F1500` - 1455 GB
- Set `Properties.sku.capacity` to:
  - One of `[2, 4, 6, 8, 10]` if using `Enterprise_E10`, `Enterprise_E20`, `Enterprise_E50` or `Enterprise_E100`.
  - Either `3` or `9` if using `EnterpriseFlash_F300`, `EnterpriseFlash_F700`, `EnterpriseFlash_F1500`.

For example:

```json
{
    "name": "testrediscache",
    "type": "Microsoft.Cache/redisEnterprise",
    "apiVersion": "2021-02-01-preview",
    "properties": {},
    "location": "australiaeast",
    "dependsOn": [],
    "sku": {
        "name": "EnterpriseFlash_F700",
        "capacity": 3
    },
    "zones": [
        "1",
        "2",
        "3"
    ],
    "tags": {},
    "resources": [
        {
            "name": "testrediscache/default",
            "type": "Microsoft.Cache/redisEnterprise/databases",
            "apiVersion": "2021-02-01-preview",
            "properties": {
                "clientProtocol": "Encrypted",
                "evictionPolicy": "NoEviction",
                "clusteringPolicy": "OSSCluster",
                "persistence": {
                    "aofEnabled": false,
                    "rdbEnabled": false
                }
            },
            "dependsOn": [
                "Microsoft.Cache/redisEnterprise/testrediscache"
            ],
            "tags": {}
        }
    ]
}
```

### Configure with Bicep

To set availability zones for Enterprise SKU Redis Cache:

- Set `zones` to `["1", "2", "3"]` or zone-redundancy.
- Set `Properties.sku.name` to one of:
  - `Enterprise_E10` - 12 GB
  - `Enterprise_E20` - 25 GB
  - `Enterprise_E50` - 50 GB
  - `Enterprise_E100` - 100 GB
  - `EnterpriseFlash_F300` - 345 GB
  - `EnterpriseFlash_F700` - 715 GB
  - `EnterpriseFlash_F1500` - 1455 GB
- Set `Properties.sku.capacity` to:
  - One of `[2, 4, 6, 8, 10]` if using `Enterprise_E10`, `Enterprise_E20`, `Enterprise_E50` or `Enterprise_E100`.
  - Either `3` or `9` if using `EnterpriseFlash_F300`, `EnterpriseFlash_F700`, `EnterpriseFlash_F1500`.

For example:

```bicep
resource testrediscache 'Microsoft.Cache/redisEnterprise@2021-02-01-preview' = {
  name: 'testrediscache'
  properties: {}
  location: 'australiaeast'
  sku: {
    name: 'EnterpriseFlash_F700'
    capacity: 3
  }
  zones: [
    '1'
    '2'
    '3'
  ]
  tags: {}
  dependsOn: []
}

resource testrediscache_default 'Microsoft.Cache/redisEnterprise/databases@2021-02-01-preview' = {
  parent: testrediscache
  name: 'default'
  properties: {
    clientProtocol: 'Encrypted'
    evictionPolicy: 'NoEviction'
    clusteringPolicy: 'OSSCluster'
    persistence: {
      aofEnabled: false
      rdbEnabled: false
    }
  }
  tags: {}
}
```

<!-- external:avm avm/res/cache/redis-enterprise availabilityZones -->

## NOTES

This rule fails when cache is not zone redundant(1, 2 and 3) when there are availability zones for the given region.

Configure `AZURE_REDISENTERPRISECACHE_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST` to set additional availability zones that need to be supported which are not in the existing [providers](https://github.com/Azure/PSRule.Rules.Azure/blob/main/data/providers/) for namespace `Microsoft.Cache` and resource type `redisEnterprise`.

```yaml
# YAML: The default AZURE_REDISENTERPRISECACHE_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST configuration option
configuration:
  AZURE_REDISENTERPRISECACHE_ADDITIONAL_REGION_AVAILABILITY_ZONE_LIST: []
```

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Enable zone redundancy for Azure Cache for Redis](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-how-to-zone-redundancy)
- [High availability for Azure Cache for Redis](https://learn.microsoft.com/azure/azure-cache-for-redis/cache-high-availability)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cache/redisenterprise)
