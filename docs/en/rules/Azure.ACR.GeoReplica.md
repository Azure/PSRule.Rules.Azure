---
reviewed: 2025-07-12
severity: Important
pillar: Reliability
category: RE:05 High-availability multi-region design
resource: Container Registry
resourceType: Microsoft.ContainerRegistry/registries
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.GeoReplica/
---

# Container Registry does not replica images to a secondary region

## SYNOPSIS

Applications or infrastructure relying on a container image may fail if the registry is not available at the time they start.

## DESCRIPTION

A container registry is stored and maintained by default in a single region.
Optionally geo-replication to one or more additional regions can be enabled to provide resilience against regional outages.

Geo-replicating container registries provides the following benefits:

- Single registry/ image/ tag names can be used across multiple regions.
- Network-close registry access within the region reduces latency.
- As images are pulled from a local replicated registry, each pull does not incur additional egress costs.

## RECOMMENDATION

Consider using a premium container registry and geo-replicating content to one or more additional regions.

## EXAMPLES

### Configure with Bicep

To deploy container registries that pass this rule:

- Set the `sku.name` property to `Premium` of the container registry.
- Add `replications` child resource with `location` set to the region to replicate to.

For example:

```bicep
resource registry 'Microsoft.ContainerRegistry/registries@2025-05-01-preview' = {
  name: name
  location: location
  sku: {
    name: 'Premium'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    adminUserEnabled: false
    anonymousPullEnabled: false
    publicNetworkAccess: 'Disabled'
    zoneRedundancy: 'Enabled'
    policies: {
      quarantinePolicy: {
        status: 'enabled'
      }
      retentionPolicy: {
        days: 30
        status: 'enabled'
      }
      softDeletePolicy: {
        retentionDays: 90
        status: 'enabled'
      }
      exportPolicy: {
        status: 'disabled'
      }
    }
  }
}

resource registryReplica 'Microsoft.ContainerRegistry/registries/replications@2025-04-01' = {
  parent: registry
  name: secondaryLocation
  location: secondaryLocation
  properties: {
    regionEndpointEnabled: true
    zoneRedundancy: 'Enabled'
  }
}
```

<!-- external:avm avm/res/container-registry/registry replications[*].location -->

### Configure with Azure template

To deploy container registries that pass this rule:

- Set the `sku.name` property to `Premium` of the container registry.
- Add `replications` child resource with `location` set to the region to replicate to.

For example to configure a container registry:

```json
{
  "type": "Microsoft.ContainerRegistry/registries",
  "apiVersion": "2025-05-01-preview",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Premium"
  },
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "adminUserEnabled": false,
    "anonymousPullEnabled": false,
    "publicNetworkAccess": "Disabled",
    "zoneRedundancy": "Enabled",
    "policies": {
      "quarantinePolicy": {
        "status": "enabled"
      },
      "retentionPolicy": {
        "days": 30,
        "status": "enabled"
      },
      "softDeletePolicy": {
        "retentionDays": 90,
        "status": "enabled"
      },
      "exportPolicy": {
        "status": "disabled"
      }
    }
  }
}
```

For example to configure a container registry replica:

```json
{
  "type": "Microsoft.ContainerRegistry/registries/replications",
  "apiVersion": "2025-04-01",
  "name": "[format('{0}/{1}', parameters('name'), parameters('secondaryLocation'))]",
  "location": "[parameters('secondaryLocation')]",
  "properties": {
    "regionEndpointEnabled": true,
    "zoneRedundancy": "Enabled"
  },
  "dependsOn": [
    "[resourceId('Microsoft.ContainerRegistry/registries', parameters('name'))]"
  ]
}
```

## NOTES

Geo-replication of a Container Registry requires the Premium SKU.

## LINKS

- [RE:05 High-availability multi-region design](https://learn.microsoft.com/azure/well-architected/reliability/highly-available-multi-region-design)
- [Geo-replicate multi-region deployments](https://learn.microsoft.com/azure/container-registry/container-registry-best-practices#geo-replicate-multi-region-deployments)
- [Geo-replication in Azure Container Registry](https://learn.microsoft.com/azure/container-registry/container-registry-geo-replication)
- [Tutorial: Prepare a geo-replicated Azure container registry](https://learn.microsoft.com/azure/container-registry/container-registry-tutorial-prepare-registry)
- [Azure deployment reference - container registry](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)
- [Azure deployment reference - container registry replication](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries/replications)
