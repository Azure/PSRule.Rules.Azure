---
reviewed: 2025-11-14
severity: Important
pillar: Reliability
category: RE:05 Redundancy
resource: Azure Managed Instance for Apache Cassandra
resourceType: Microsoft.DocumentDB/cassandraClusters/dataCenters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.MICassandra.AvailabilityZone/
---

# Use zone redundant Azure Managed Instance for Apache Cassandra clusters

## SYNOPSIS

Use zone redundant Azure Managed Instance for Apache Cassandra clusters in supported regions to improve reliability.

## DESCRIPTION

Azure Managed Instance for Apache Cassandra supports zone redundancy through availability zones.
When availability zones are enabled, nodes are physically separated across multiple zones within an Azure region.

Availability zones are unique physical locations within an Azure region.
Each zone is made up of one or more datacenters equipped with independent power, cooling, and networking infrastructure.
This physical separation ensures that if one zone experiences an outage,
your Cassandra cluster continues to serve read and write requests from nodes in other zones without downtime.

With zone redundancy enabled, Azure Managed Instance for Apache Cassandra provides:

- Automatic distribution of nodes across zones.
- Continuous availability during zonal failures.
- Enhanced durability by maintaining multiple replicas across separate physical locations.
- Protection against datacenter-level disasters while maintaining low-latency access.

Zone redundancy must be configured when you create a data center by setting `availabilityZone` to `true`.
This setting cannot be changed after the datacenter is created.
Zone redundancy is only available in regions that support availability zones.

## RECOMMENDATION

Consider using locations configured with zone redundancy to improve workload resiliency of Azure Managed Instance for Apache Cassandra clusters.

## EXAMPLES

### Configure with Azure template

To deploy clusters that pass this rule:

- Set `properties.availabilityZone` to `true`.

For example:

```json
{
  "type": "Microsoft.DocumentDB/cassandraClusters/dataCenters",
  "apiVersion": "2024-11-15",
  "name": "[format('{0}/{1}', parameters('clusterName'), parameters('dataCenterName'))]",
  "location": "[parameters('location')]",
  "properties": {
    "dataCenterLocation": "[parameters('location')]",
    "delegatedSubnetId": "[parameters('delegatedSubnetId')]",
    "nodeCount": 3,
    "sku": "Standard_E8s_v5",
    "diskCapacity": 4,
    "availabilityZone": true
  }
}
```

### Configure with Bicep

To deploy clusters that pass this rule:

- Set `properties.availabilityZone` to `true`.

For example:

```bicep
resource dataCenter 'Microsoft.DocumentDB/cassandraClusters/dataCenters@2024-11-15' = {
  parent: cluster
  name: datacenterName
  location: location
  properties: {
    dataCenterLocation: location
    delegatedSubnetId: delegatedSubnetId
    nodeCount: 3
    sku: 'Standard_E8s_v5'
    diskCapacity: 4
    availabilityZone: true
  }
}
```

## NOTES

This rule only applies to Azure Managed Instance for Apache Cassandra deployment model.

## LINKS

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [Azure regions with availability zone support](https://learn.microsoft.com/azure/reliability/availability-zones-service-support)
- [Reliability: Level 1](https://learn.microsoft.com/azure/well-architected/reliability/maturity-model?tabs=level1)
- [Architecture strategies for using availability zones and regions](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Best practices for high availability and disaster recovery](https://learn.microsoft.com/azure/managed-instance-apache-cassandra/resilient-applications)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/cassandraclusters/datacenters)
