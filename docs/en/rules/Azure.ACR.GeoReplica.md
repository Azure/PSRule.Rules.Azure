---
severity: Important
pillar: Reliability
category: RE:05 High-availability multi-region design
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.GeoReplica/
---

# Geo-replicate container images

## SYNOPSIS

Use geo-replicated container registries to compliment a multi-region container deployments.

## DESCRIPTION

A container registry is stored and maintained by default in a single region.
Optionally geo-replication to one or more additional regions can be enabled.

Geo-replicating container registries provides the following benefits:

- Single registry/ image/ tag names can be used across multiple regions.
- Network-close registry access within the region reduces latency.
- As images are pulled from a local replicated registry, each pull does not incur additional egress costs.

## RECOMMENDATION

Consider using a geo-replicated container registry for multi-region deployments.

## EXAMPLES

### Configure with Azure template

To enable geo-replication for Container Registries that pass this rule:

- Set `sku.name` to `Premium` (required for geo-replication).
- Add `replications` child resource with `location` set to the region to replicate to.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "metadata": {
    "_generator": {
      "name": "bicep",
      "version": "0.5.6.12127",
      "templateHash": "12610175857982700190"
    }
  },
  "parameters": {
    "acrName": {
      "type": "string",
      "defaultValue": "[format('acr{0}', uniqueString(resourceGroup().id))]",
      "maxLength": 50,
      "minLength": 5,
      "metadata": {
        "description": "Globally unique name of your Azure Container Registry"
      }
    },
    "acrAdminUserEnabled": {
      "type": "bool",
      "defaultValue": false,
      "metadata": {
        "description": "Enable admin user that has push / pull permission to the registry."
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "Location for registry home replica."
      }
    },
    "acrSku": {
      "type": "string",
      "defaultValue": "Premium",
      "allowedValues": [
        "Premium"
      ],
      "metadata": {
        "description": "Tier of your Azure Container Registry. Geo-replication requires Premium SKU."
      }
    },
    "acrReplicaLocation": {
      "type": "string",
      "metadata": {
        "description": "Short name for registry replica location."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.ContainerRegistry/registries",
      "apiVersion": "2023-11-01-preview",
      "name": "[parameters('acrName')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "[parameters('acrSku')]"
      },
      "tags": {
        "displayName": "Container Registry",
        "container.registry": "[parameters('acrName')]"
      },
      "properties": {
        "adminUserEnabled": "[parameters('acrAdminUserEnabled')]"
      }
    },
    {
      "type": "Microsoft.ContainerRegistry/registries/replications",
      "apiVersion": "2023-11-01-preview",
      "name": "[format('{0}/{1}', parameters('acrName'), parameters('acrReplicaLocation'))]",
      "location": "[parameters('acrReplicaLocation')]",
      "properties": {},
      "dependsOn": [
        "[resourceId('Microsoft.ContainerRegistry/registries', parameters('acrName'))]"
      ]
    }
  ],
  "outputs": {
    "acrLoginServer": {
      "type": "string",
      "value": "[reference(resourceId('Microsoft.ContainerRegistry/registries', parameters('acrName'))).loginServer]"
    }
  }
}
```

### Configure with Bicep

To deploy Container Registries that pass this rule:

- Set `sku.name` to `Premium` (required for geo-replication).
- Add `replications` child resource with `location` set to the region to replicate to.

For example:

```bicep
resource containerRegistry 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
  name: acrName
  location: location
  sku: {
    name: 'Premium'
  }
  tags: {
    displayName: 'Container Registry'
    'container.registry': acrName
  }
  properties: {
    adminUserEnabled: acrAdminUserEnabled
  }
}

resource containerRegistryReplica 'Microsoft.ContainerRegistry/registries/replications@2023-11-01-preview' = {
  parent: containerRegistry
  name: '${acrReplicaLocation}'
  location: acrReplicaLocation
  properties: {
  }
}
```

## NOTES

This rule applies when analyzing resources deployed (in-flight) to Azure.

## LINKS

- [RE:05 High-availability multi-region design](https://learn.microsoft.com/azure/well-architected/reliability/highly-available-multi-region-design)
- [Geo-replicate multi-region deployments](https://learn.microsoft.com/azure/container-registry/container-registry-best-practices#geo-replicate-multi-region-deployments)
- [Geo-replication in Azure Container Registry](https://learn.microsoft.com/azure/container-registry/container-registry-geo-replication)
- [Tutorial: Prepare a geo-replicated Azure container registry](https://learn.microsoft.com/azure/container-registry/container-registry-tutorial-prepare-registry)
