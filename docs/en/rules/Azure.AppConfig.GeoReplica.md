---
severity: Important
pillar: Reliability
category: Data management
resource: App Configuration
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppConfig.GeoReplica/
---

# Geo-replicate app configuration store

## SYNOPSIS

Consider replication for app configuration store to ensure resiliency to region outages.

## DESCRIPTION

A app configuration store is stored and maintained by default in a single region.

The app configuration geo-replication feature allows you to replicate your configuration store at-will to the regions of your choice.
Each new `replica` will be in a different region and creates a new endpoint for your applications to send requests to.
The original endpoint of your configuration store is called the `Origin`.
The origin can't be removed, but otherwise behaves like any replica.

Replicating your configuration store adds the following benefits:

- Added resiliency for Azure outages.
- Redistribution of request limits.
- Regional compartmentalization.

Geo-replication is currently a **preview** feature.
During the preview geo-replication has additional limitations including support and regional availability.

## RECOMMENDATION

Consider replication for app configuration store to ensure resiliency to region outages.

## EXAMPLES

### Configure with Azure template

To deploy App Configuration Stores that pass this rule:

- Set `sku.name` to `Standard` (required for geo-replication).
- Deploy a replica sub-resource (child resource).
- Set `location` on replica sub-resource to a different location than the app configuration store.

For example:

```json
{
  "parameters": {
    "appConfigName": {
      "type": "string",
      "defaultValue": "configstore01",
      "metadata": {
        "description": "The name of the app configuration store."
      }
    },
    "replicaName": {
      "type": "string",
      "defaultValue": "replica01",
      "metadata": {
        "description": "The name of the replica."
      }
    },
    "appConfigLocation": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "The location resources will be deployed."
      }
    },
    "replicaLocation": {
      "type": "string",
      "defaultValue": "northeurope",
      "metadata": {
        "description": "The location where the replica will be deployed."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.AppConfiguration/configurationStores",
      "apiVersion": "2022-05-01",
      "name": "[parameters('appConfigName')]",
      "location": "[parameters('appConfigLocation')]",
      "sku": {
        "name": "standard"
      },
      "properties": {
        "disableLocalAuth": true,
        "enablePurgeProtection": true
      }
    },
    {
      "type": "Microsoft.AppConfiguration/configurationStores/replicas",
      "apiVersion": "2022-03-01-preview",
      "name": "[format('{0}/{1}', parameters('appConfigName'), parameters('replicaName'))]",
      "location": "[parameters('replicaLocation')]",
      "dependsOn": [
        "[resourceId('Microsoft.AppConfiguration/configurationStores', parameters('appConfigName'))]"
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
@description('The name of the app configuration store.')
param appConfigName string = 'configstore01'

@description('The name of the replica.')
param replicaName string = 'replica01'

@description('The location resources will be deployed.')
param appConfigLocation string = resourceGroup().location

@description('The location where the replica will be deployed.')
param replicaLocation string = 'northeurope'

resource store 'Microsoft.AppConfiguration/configurationStores@2022-05-01' = {
  name: appConfigName
  location: appConfigLocation
  sku: {
    name: 'standard'
  }
  properties: {
    disableLocalAuth: true
    enablePurgeProtection: true
  }
}

resource replica 'Microsoft.AppConfiguration/configurationStores/replicas@2022-03-01-preview' = {
  name: replicaName
  location: replicaLocation
  parent: store
}
```

## LINKS

- [Resiliency and dependencies](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-resiliency)
- [Resiliency and diaster recovery](https://learn.microsoft.com/azure/azure-app-configuration/concept-disaster-recovery)
- [Geo-replication overview](https://learn.microsoft.com/azure/azure-app-configuration/concept-geo-replication)
- [Enable geo-replication](https://learn.microsoft.com/azure/azure-app-configuration/howto-geo-replication)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores/replicas)
