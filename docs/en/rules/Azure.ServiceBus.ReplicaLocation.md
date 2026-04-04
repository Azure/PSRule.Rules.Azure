---
reviewed: 2026-03-26
severity: Important
pillar: Security
category: SE:01 Security baseline
resource: Service Bus
resourceType: Microsoft.ServiceBus/namespaces
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ServiceBus.ReplicaLocation/
---

# Service Bus namespace replica location is not allowed

## SYNOPSIS

The replica location determines the country or region where the data is stored and processed.

## DESCRIPTION

Azure supports deployment to many locations around the world called regions.
Many organizations have requirements or legal obligations that limit where data can be stored or processed.
This is commonly known as data residency.

Service Bus namespaces can be configured with geo-replication to replicate data to one or more secondary regions.
Each configured region stores and processes data, making it subject to local legal requirements in that region.

To align with your organizational requirements, you may choose to limit the regions that geo-replication replicas can be deployed to.
This allows you to ensure that resources are deployed to regions that meet your data residency requirements.

Some resources, particularly those related to preview services or features, may not be available in all regions.

## RECOMMENDATION

Consider deploying Service Bus namespace geo-replication replicas to allowed regions to align with your organizational requirements.
Also consider using Azure Policy to enforce allowed regions at runtime.

## EXAMPLES

### Configure with Bicep

To deploy namespaces that pass this rule:

- Set the `locationName` property of each replica location specified in `properties.geoDataReplication.locations` to an allowed region.

For example:

```bicep
resource withReplication 'Microsoft.ServiceBus/namespaces@2025-05-01-preview' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'Premium'
  }
  properties: {
    disableLocalAuth: true
    minimumTlsVersion: '1.2'
    geoDataReplication: {
      maxReplicationLagDurationInSeconds: 300
      locations: [
        {
          locationName: location
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

### Configure with Azure template

To deploy namespaces that pass this rule:

- Set the `locationName` property of each replica location specified in `properties.geoDataReplication.locations` to an allowed region.

For example:

```json
{
  "type": "Microsoft.ServiceBus/namespaces",
  "apiVersion": "2025-05-01-preview",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "identity": {
    "type": "SystemAssigned"
  },
  "sku": {
    "name": "Premium"
  },
  "properties": {
    "disableLocalAuth": true,
    "minimumTlsVersion": "1.2",
    "geoDataReplication": {
      "maxReplicationLagDurationInSeconds": 300,
      "locations": [
        {
          "locationName": "[parameters('location')]",
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

## NOTES

This rule requires one or more allowed regions to be configured.
By default, all regions are allowed.

Also note that Service Bus geo-replication requires a Premium SKU namespace.
As a result, this rule only applies to namespaces using the Premium SKU that already have geo-replication configured.

### Rule configuration

<!-- module:config rule AZURE_RESOURCE_ALLOWED_LOCATIONS -->

To configure this rule set the `AZURE_RESOURCE_ALLOWED_LOCATIONS` configuration value to a set of allowed regions.

For example:

```yaml
configuration:
  AZURE_RESOURCE_ALLOWED_LOCATIONS:
  - australiaeast
  - australiasoutheast
```

If you configure this `AZURE_RESOURCE_ALLOWED_LOCATIONS` configuration value,
also consider setting `AZURE_RESOURCE_GROUP` the configuration value to when resources use the location of the resource group.

For example:

```yaml
configuration:
  AZURE_RESOURCE_GROUP:
    location: australiaeast
```

## LINKS

- [SE:01 Security baseline](https://learn.microsoft.com/azure/well-architected/security/establish-baseline)
- [Geo-replication](https://learn.microsoft.com/azure/service-bus-messaging/service-bus-geo-replication)
- [Configure geo-replication](https://learn.microsoft.com/azure/service-bus-messaging/service-bus-geo-replication#setup)
- [Data residency in Azure](https://azure.microsoft.com/explore/global-infrastructure/data-residency/#overview)
- [Azure geographies](https://azure.microsoft.com/explore/global-infrastructure/geographies/#geographies)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.servicebus/namespaces)
