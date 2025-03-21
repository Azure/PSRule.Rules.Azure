---
reviewed: 2021-11-13
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Container Registry
resourceType: Microsoft.ContainerRegistry/registries
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.MinSku/
ms-content-id: a70d16d4-3717-4eef-b588-8a0204860d6e
---

# Use ACR production SKU

## SYNOPSIS

ACR should use the Premium or Standard SKU for production deployments.

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

### Configure with Azure template

To deploy registries that pass this rule:

- Set the `sku.name` property to `Premium` or `Standard`.

For example:

```json
{
  "type": "Microsoft.ContainerRegistry/registries",
  "apiVersion": "2023-01-01-preview",
  "name": "[parameters('registryName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Premium"
  },
  "identity": {
    "type": "SystemAssigned"
  },
  "properties": {
    "adminUserEnabled": false,
    "policies": {
      "quarantinePolicy": {
        "status": "enabled"
      },
      "trustPolicy": {
        "status": "enabled",
        "type": "Notary"
      },
      "retentionPolicy": {
        "days": 30,
        "status": "enabled"
      },
      "softDeletePolicy": {
        "retentionDays": 90,
        "status": "enabled"
      }
    }
  }
}
```

### Configure with Bicep

To deploy registries that pass this rule:

- Set the `sku.name` property to `Premium` or `Standard`.

For example:

```bicep
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: registryName
  location: location
  sku: {
    name: 'Premium'
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    adminUserEnabled: false
    policies: {
      quarantinePolicy: {
        status: 'enabled'
      }
      trustPolicy: {
        status: 'enabled'
        type: 'Notary'
      }
      retentionPolicy: {
        days: 30
        status: 'enabled'
      }
      softDeletePolicy: {
        retentionDays: 90
        status: 'enabled'
      }
    }
  }
}
```

<!-- external:avm avm/res/container-registry/registry:0.5.1 acrSku -->

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Azure Container Registry SKUs](https://learn.microsoft.com/azure/container-registry/container-registry-skus)
- [Geo-replication in Azure Container Registry](https://learn.microsoft.com/azure/container-registry/container-registry-geo-replication)
- [Best practices for Azure Container Registry](https://learn.microsoft.com/azure/container-registry/container-registry-best-practices#geo-replicate-multi-region-deployments)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)
