---
reviewed: 2025-10-10
severity: Important
pillar: Security
category: SE:01 Security baseline
resource: App Configuration
resourceType: Microsoft.AppConfiguration/configurationStores,Microsoft.AppConfiguration/configurationStores/replicas
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppConfig.ReplicaLocation/
---

# App Configuration Store replica location is not allowed

## SYNOPSIS

The replication location determines the country or region where configuration data is stored and processed.

## DESCRIPTION

Azure supports deployment to many locations around the world called regions.
Many organizations have requirements or legal obligations that limit where data can be stored or processed.
This is commonly known as data residency.

App Configuration Stores support geo-replication to multiple regions.
When geo-replication is enabled, configuration data is replicated to the specified regions.
Data in these replica regions is stored, processed, and subject to local legal requirements in those regions.

To align with your organizational requirements, you may choose to limit the regions that replicas can be configured.
This allows you to ensure that configuration data replicates to regions that meet your data residency requirements.

Some regions, particularly those related to preview services or features, may not be available for all services.

## RECOMMENDATION

Consider configuring App Configuration Store replicas to allowed regions to align with your organizational requirements.

## EXAMPLES

### Configure with Bicep

To deploy App Configuration Stores that pass this rule:

- Set the `location` property of each replica to an allowed region, in the list of supported regions.

For example:

```bicep
resource store 'Microsoft.AppConfiguration/configurationStores@2024-06-01' = {
  name: name
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    disableLocalAuth: true
    enablePurgeProtection: true
    publicNetworkAccess: 'Disabled'
  }
}

resource replica 'Microsoft.AppConfiguration/configurationStores/replicas@2024-06-01' = {
  parent: store
  name: replicaName
  location: replicaLocation
}
```

<!-- external:avm avm/res/app-configuration/configuration-store replicaLocations -->

### Configure with Azure template

To deploy App Configuration Stores that pass this rule:

- Set the `location` property of each replica to an allowed region, in the list of supported regions.

For example:

```json
{
  "resources": [
    {
      "type": "Microsoft.AppConfiguration/configurationStores",
      "apiVersion": "2024-06-01",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "standard"
      },
      "properties": {
        "disableLocalAuth": true,
        "enablePurgeProtection": true,
        "publicNetworkAccess": "Disabled"
      }
    },
    {
      "type": "Microsoft.AppConfiguration/configurationStores/replicas",
      "apiVersion": "2024-06-01",
      "name": "[format('{0}/{1}', parameters('name'), parameters('replicaName'))]",
      "location": "[parameters('replicaLocation')]",
      "dependsOn": [
        "[resourceId('Microsoft.AppConfiguration/configurationStores', parameters('name'))]"
      ]
    }
  ]
}
```

## NOTES

Geo-replication of an App Configuration Store requires the Standard SKU.

This rule requires one or more allowed regions to be configured.
By default, all regions are allowed.

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
also consider setting `AZURE_RESOURCE_GROUP` the configuration value when resources use the location of the resource group.

For example:

```yaml
configuration:
  AZURE_RESOURCE_GROUP:
    location: australiaeast
```

## LINKS

- [SE:01 Security baseline](https://learn.microsoft.com/azure/well-architected/security/establish-baseline)
- [Geo-replication in Azure App Configuration](https://learn.microsoft.com/azure/azure-app-configuration/concept-geo-replication)
- [Enable geo-replication](https://learn.microsoft.com/azure/azure-app-configuration/howto-geo-replication)
- [Data residency in Azure](https://azure.microsoft.com/explore/global-infrastructure/data-residency/#overview)
- [Azure geographies](https://azure.microsoft.com/explore/global-infrastructure/geographies/#geographies)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores/replicas)
