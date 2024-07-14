---
severity: Important
pillar: Reliability
category: RE:05 Redundancy
resource: Service Bus
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ServiceBus.GeoReplica/
---

# Geo-replication

## SYNOPSIS

Enhance resilience to regional outages by replicating namespaces.

## DESCRIPTION

By default, an service bus namespace and its data and metadata is in a single region.

The geo-replication feature ensures that the metadata and data of a namespace are continuously replicated from a primary region to one or more secondary regions.

The following will be replicated:

- Queues, topics, subscriptions, filters.
- Data, which resides in the entities.
- All state changes and property changes executed against the messages within a namespace.
- Namespace configuration.

Replicating your namespace adds the following benefits:

- Added resiliency for localized outages contained to a region.
- Regional compartmentalization.

This feature allows promoting any secondary region to primary, reassigning the namespace name and switching roles between regions. Promotion is nearly instantaneous.

There are currently several limitations to the feature. For more details, refer to the documentation.

## RECOMMENDATION

Consider replicating service bus namespaces to improve resiliency to region outages.

## EXAMPLES

### Configure with Azure template

To deploy namespaces that pass this rule:

- Set `sku.name` to `Premium`.
- Configure the `properties.geoDataReplication.locations` array with two or more supported region elements.

For example:

```json
{
  "type": "Microsoft.ServiceBus/namespaces",
  "apiVersion": "2023-01-01-preview",
  "name": "[parameters('serviceBusName')]",
  "location": "[parameters('primaryLocation')]",
  "sku": {
    "name": "Premium",
    "tier": "Premium",
    "capacity": 1
  },
  "properties": {
    "geoDataReplication": {
      "maxReplicationLagDurationInSeconds": "[parameters('maxReplicationLagInSeconds')]",
      "locations": [
        {
          "locationName": "[parameters('primaryLocation')]",
          "roleType": "Primary"
        },
        {
          "locationName": "[parameters('secondaryLocation')]",
          "roleType": "Secondary"
        }
      ]
    }
  }
}
```

### Configure with Bicep

To deploy namespaces that pass this rule:

- Set `sku.name` to `Premium`.
- Configure the `properties.geoDataReplication.locations` array with two or more supported region elements.

For example:

```bicep
resource sb 'Microsoft.ServiceBus/namespaces@2023-01-01-preview' = {
  name: serviceBusName
  location: primaryLocation
  sku: {
    name: 'Premium'
    tier: 'Premium'
    capacity: 1
  }
  properties: {
    geoDataReplication: {
      maxReplicationLagDurationInSeconds: maxReplicationLagInSeconds
      locations: [
        {
          locationName: primaryLocation
          roleType: 'Primary'
        }
        {
          locationName: secondaryLocation
          roleType: 'Secondary'
        }
      ]
    }
  }
}
```

## NOTES

This feature is only supported for the `Premium` SKU.

This feature is currently in preview.

## LINKS

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [Geo-replication](https://learn.microsoft.com/azure/service-bus-messaging/service-bus-geo-replication)
- [Configure geo-replication](https://learn.microsoft.com/azure/service-bus-messaging/service-bus-geo-replication#setup)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.servicebus/namespaces)
