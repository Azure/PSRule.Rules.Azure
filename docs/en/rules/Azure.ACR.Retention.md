---
severity: Important
pillar: Cost Optimization
category: CO:10 Data costs
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.Retention/
---

# Configure ACR retention policies

## SYNOPSIS

Use a retention policy to cleanup untagged manifests.

## DESCRIPTION

Retention policy is a configurable option of Premium Azure Container Registry (ACR).
When a retention policy is configured, untagged manifests in the registry are automatically deleted.
A manifest is untagged when a more recent image is pushed using the same tag. i.e. latest.

The retention policy (in days) can be set to 0-365.
The default is 7 days.

To configure a retention policy, the container registry must be using a Premium SKU.

## RECOMMENDATION

Consider enabling a retention policy for untagged manifests.

## EXAMPLES

### Configure with Azure template

To deploy Container Registries that pass this rule:

- Set `properties.retentionPolicy.status` to `enabled`.

For example:

```json
{
  "type": "Microsoft.ContainerRegistry/registries",
  "apiVersion": "2023-11-01-preview",
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

To deploy Container Registries that pass this rule:

- Set `properties.retentionPolicy.status` to `enabled`.

For example:

```bicep
resource acr 'Microsoft.ContainerRegistry/registries@2023-11-01-preview' = {
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

## NOTES

Retention policies for Azure Container Registry is currently in preview.

## LINKS

- [CO:10 Data costs](https://learn.microsoft.com/azure/well-architected/cost-optimization/optimize-data-costs)
- [Set a retention policy for untagged manifests](https://learn.microsoft.com/azure/container-registry/container-registry-retention-policy)
- [Lock a container image in an Azure container registry](https://learn.microsoft.com/azure/container-registry/container-registry-image-lock)
- [Scalable storage](https://learn.microsoft.com/azure/container-registry/container-registry-storage#scalable-storage)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)
