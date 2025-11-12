---
severity: Important
pillar: Reliability
category: RE:05 Regions and availability zones
resource: Azure Managed Instance for Apache Cassandra
resourceType: Microsoft.DocumentDB/cassandraClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cassandra.AvailabilityZone/
---

# Cassandra data centers should use Availability zones in supported regions

## SYNOPSIS

Deploy Azure Managed Instance for Apache Cassandra data centers using availability zones in supported regions to ensure high availability and resilience.

## DESCRIPTION

Azure Managed Instance for Apache Cassandra data centers using availability zones improve reliability and ensure availability during failure scenarios affecting a data center within a region.
When availability zones are enabled, nodes are physically separated across multiple zones within a region.
By distributing nodes across availability zones, data centers can continue running even if one zone experiences an outage.

For a replication factor of 3, availability zone support ensures that each replica is placed in a different availability zone, preventing a zonal outage from affecting your database or application.

## RECOMMENDATION

Consider enabling availability zones for Azure Managed Instance for Apache Cassandra data centers deployed in supported regions.

## EXAMPLES

### Configure with Azure template

To enable availability zones for a Cassandra data center:

- Set `properties.availabilityZone` to `true`.

For example:

```json
{
  "type": "Microsoft.DocumentDB/cassandraClusters/dataCenters",
  "apiVersion": "2023-11-15",
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

To enable availability zones for a Cassandra data center:

- Set `properties.availabilityZone` to `true`.

For example:

```bicep
resource dataCenter 'Microsoft.DocumentDB/cassandraClusters/dataCenters@2023-11-15' = {
  name: '${clusterName}/${dataCenterName}'
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

### Configure with Azure CLI

To enable availability zones for a Cassandra data center:

```bash
az managed-cassandra datacenter create \
  --resource-group $resourceGroupName \
  --cluster-name $clusterName \
  --data-center-name $dataCenterName \
  --data-center-location $location \
  --delegated-subnet-id $delegatedSubnetId \
  --node-count 3 \
  --sku Standard_E8s_v5 \
  --disk-capacity 4 \
  --availability-zone true
```

### Configure with Azure PowerShell

To enable availability zones for a Cassandra data center:

```powershell
New-AzManagedCassandraDatacenter `
  -ResourceGroupName $resourceGroupName `
  -ClusterName $clusterName `
  -DataCenterName $dataCenterName `
  -Location $location `
  -DelegatedSubnetId $delegatedSubnetId `
  -NodeCount 3 `
  -Sku Standard_E8s_v5 `
  -DiskCapacity 4 `
  -UseAvailabilityZone $true
```

## NOTES

This rule applies when analyzing resources deployed to Azure using *pre-flight* and *in-flight* data.

This rule fails when `properties.availabilityZone` is `false` or not set when there are availability zones available for the given region.

Availability zones are not supported in all Azure regions.
Deployments will fail if you select a region where availability zones are not supported.

## LINKS

- [RE:05 Regions and availability zones](https://learn.microsoft.com/azure/well-architected/reliability/regions-availability-zones)
- [Best practices for high availability and disaster recovery](https://learn.microsoft.com/azure/managed-instance-apache-cassandra/resilient-applications)
- [Create an Azure Managed Instance for Apache Cassandra cluster](https://learn.microsoft.com/azure/managed-instance-apache-cassandra/create-cluster-cli)
- [Azure regions with availability zones](https://learn.microsoft.com/azure/reliability/availability-zones-region-support)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.documentdb/cassandraclusters/datacenters)
