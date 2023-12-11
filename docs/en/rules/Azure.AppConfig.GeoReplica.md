---
reviewed: 2023-12-11
severity: Important
pillar: Reliability
category: RE:05 Redundancy
resource: App Configuration
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppConfig.GeoReplica/
---

# Geo-replicate app configuration store

## SYNOPSIS

Replicate app configuration store across all points of presence for an application.

## DESCRIPTION

By default, an app configuration store is stored and maintained in a single region.

The app configuration geo-replication feature allows you to replicate your configuration store to additional regions.
Each new _replica_ will be in a different region with a new endpoint for your applications to send requests to.
The original endpoint of your configuration store is called the _origin_.
The origin can't be removed, but otherwise behaves like any replica.

Replicating your configuration store adds the following benefits:

- Added resiliency for localized outages contained to a region.
- Redistribution of request limits.
- Regional compartmentalization.

When considering where to place replicas, consider the following; where does the application run from?

- For server-side applications, consider deploying replicas to regions where the application is hosted and recovered.
- For client-side applications, consider deploying replicas to regions closest to where the users are located.

## RECOMMENDATION

Consider replicating app configuration stores to improve resiliency to region outages.

## EXAMPLES

### Configure with Azure template

To deploy App Configuration Stores that pass this rule:

- Set `sku.name` to `Standard` (required for geo-replication).
- Deploy a replica sub-resource (child resource).
- Set `location` on replica sub-resource to a different location than the app configuration store.

For example:

```json
{
  "resources": [
    {
      "type": "Microsoft.AppConfiguration/configurationStores",
      "apiVersion": "2023-03-01",
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
      "apiVersion": "2023-03-01",
      "name": "[format('{0}/{1}', parameters('name'), parameters('replicaName'))]",
      "location": "[parameters('replicaLocation')]",
      "dependsOn": [
        "[resourceId('Microsoft.AppConfiguration/configurationStores', parameters('name'))]"
      ]
    }
  ]
}
```

### Configure with Bicep

To deploy App Configuration Stores that pass this rule:

- Set `sku.name` to `Standard` (required for geo-replication).
- Deploy a replica sub-resource (child resource).
- Set `location` on replica sub-resource to a different location than the app configuration store.

For example:

```bicep
resource store 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
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

resource replica 'Microsoft.AppConfiguration/configurationStores/replicas@2023-03-01' = {
  parent: store
  name: replicaName
  location: replicaLocation
}
```

### Configure with Bicep Public Registry

To deploy App Configuration Stores that pass this rule:

- Set `params.skuName` to `Standard` (required for geo-replication).
- Configure one or more replicas by setting `params.replicas` to an array of objects.
- Set `location` on each replica to a different location than the app configuration store.

For example:

```bicep
module br_public_store 'br/public:app/app-configuration:1.1.2' = {
  name: 'store'
  params: {
    skuName: 'Standard'
    disableLocalAuth: true
    enablePurgeProtection: true
    publicNetworkAccess: 'Disabled'
    replicas: [
      {
        name: 'eastus'
        location: 'eastus'
      }
    ]
  }
}
```

## LINKS

- [RE:05 Redundancy](https://learn.microsoft.com/azure/well-architected/reliability/redundancy)
- [Resiliency and diaster recovery](https://learn.microsoft.com/azure/azure-app-configuration/concept-disaster-recovery)
- [Geo-replication overview](https://learn.microsoft.com/azure/azure-app-configuration/concept-geo-replication)
- [Enable geo-replication](https://learn.microsoft.com/azure/azure-app-configuration/howto-geo-replication)
- [Bicep public registry](https://azure.github.io/bicep-registry-modules/#app)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores/replicas)
