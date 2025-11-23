---
reviewed: 2025-11-19
severity: Important
pillar: Reliability
category: RE:05 Redundancy
resource: Event Hub
resourceType: Microsoft.EventHub/namespaces
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EventHub.AvailabilityZone/
---

# Use zone redundant Event Hub namespaces

## SYNOPSIS

Use zone redundant Event Hub namespaces in supported regions to improve reliability.

## DESCRIPTION

Azure Event Hubs supports zone redundancy to provide enhanced resiliency and high availability.
When zone redundancy is enabled, Event Hubs automatically replicates namespace metadata
and event data across multiple availability zones within a region.

Availability zones are unique physical locations within an Azure region.
Each zone is made up of one or more datacenters equipped with independent power, cooling, and networking.
This physical separation protects your Event Hubs namespace from zone-level failures,
ensuring continuous availability even if an entire availability zone experiences an outage.

With zone redundancy enabled, Azure Event Hubs provides:

- Synchronous replication of metadata and events across zones.
- Continuous availability during zonal failures.
- Protection against datacenter-level disasters while maintaining low-latency access.

Zone redundancy must be configured when you create an Event Hub namespace by setting `zoneRedundant` to `true`.
This setting cannot be changed after the namespace is created.
Zone redundancy is only available in regions that support availability zones.

## RECOMMENDATION

Consider using using a minimum of Standard Event Hub namespaces configured with zone redundancy to improve workload resiliency.

## EXAMPLES

### Configure with Azure template

To deploy Event Hub namespaces that pass this rule:

- Set the `properties.zoneRedundant` property to `true`.

For example:

```json
{
  "type": "Microsoft.EventHub/namespaces",
  "apiVersion": "2024-01-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard",
    "tier": "Standard"
  },
  "properties": {
    "disableLocalAuth": true,
    "minimumTlsVersion": "1.2",
    "zoneRedundant": true
  }
}
```

### Configure with Bicep

To deploy Event Hub namespaces that pass this rule:

- Set the `properties.zoneRedundant` property to `true`.

For example:

```bicep
resource eventHubNamespace 'Microsoft.EventHub/namespaces@2024-01-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard'
    tier: 'Standard'
  }
  properties: {
    disableLocalAuth: true
    minimumTlsVersion: '1.2'
    zoneRedundant: true
  }
}
```

<!-- external:avm avm/res/event-hub/namespace zoneRedundant -->

## NOTES

Availability zones is supported on Standard, Premium, and Dedicated tiers.

For the Dedicated tier, availability zones require a minimum of three capacity units (CUs).

## LINKS

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [Reliability: Level 1](https://learn.microsoft.com/azure/well-architected/reliability/maturity-model?tabs=level1)
- [Architecture strategies for using availability zones and regions](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Azure regions with availability zone support](https://learn.microsoft.com/azure/reliability/availability-zones-service-support)
- [High availability with Azure Event Hubs](https://learn.microsoft.com/azure/reliability/reliability-event-hubs)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.eventhub/namespaces)
