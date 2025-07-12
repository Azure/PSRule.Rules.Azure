---
reviewed: 2025-07-12
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Container Registry
resourceType: Microsoft.ContainerRegistry/registries
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.MinSku/
ms-content-id: a70d16d4-3717-4eef-b588-8a0204860d6e
---

# Container Registry SKU is not suitable for production workloads

## SYNOPSIS

The Basic SKU provides limited performance and features for production container registry workloads.

## DESCRIPTION

Azure Container Registry (ACR) provides a range of different service tiers (also known as SKUs).
These service tiers provide different levels of performance and features.

Three service tiers are available: Basic, Standard, and Premium.
Basic container registries are only recommended for non-production deployments.
Use a minimum of Standard for production container registries.

The Premium SKU provides higher image throughput and included storage, and is required for:

- Geo-replication
- Availability zones
- Private Endpoints
- Firewall restrictions
- Tokens and scope-maps

## RECOMMENDATION

Consider using the Premium Container Registry SKU for production deployments.

## EXAMPLES

### Configure with Bicep

To deploy registries that pass this rule:

- Set the `sku.name` property to `Premium` or `Standard`.

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
```

<!-- external:avm avm/res/container-registry/registry acrSku -->

### Configure with Azure template

To deploy registries that pass this rule:

- Set the `sku.name` property to `Premium` or `Standard`.

For example:

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

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Azure Container Registry SKUs](https://learn.microsoft.com/azure/container-registry/container-registry-skus)
- [Geo-replication in Azure Container Registry](https://learn.microsoft.com/azure/container-registry/container-registry-geo-replication)
- [Best practices for Azure Container Registry](https://learn.microsoft.com/azure/container-registry/container-registry-best-practices#geo-replicate-multi-region-deployments)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)
