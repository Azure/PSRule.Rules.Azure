---
severity: Important
pillar: Reliability
category: Data management
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.SoftDelete/
---

# Use ACR soft delete policy

## SYNOPSIS

Azure Container Registries should have soft delete policy enabled.

## DESCRIPTION

Azure Container Registry (ACR) allows you to enable the soft delete policy to recover any accidentally deleted artifacts for a set retention period.

This feature is available in all the service tiers (also known as SKUs).
For information about registry service tiers, see Azure Container Registry service tiers.

Once you enable the soft delete policy, ACR manages the deleted artifacts as the soft deleted artifacts with a set retention period.
Thereby you have ability to list, filter, and restore the soft deleted artifacts.
Once the retention period is complete, all the soft deleted artifacts are auto-purged.

Current preview limitations:

- ACR currently doesn't support manually purging soft deleted artifacts.
- The soft delete policy doesn't support a geo-replicated registry.
- ACR doesn't allow enabling both the retention policy and the soft delete policy. See retention policy for untagged manifests.

## RECOMMENDATION

Azure Container Registries should have soft delete enabled to enable recovery of accidentally deleted artifacts.

## EXAMPLES

### Configure with Azure template

To deploy an Azure Container Registry that pass this rule:

- Set the `properties.policies.softDeletePolicy.status` property to `enabled`.

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

To deploy an Azure Container Registry that pass this rule:

- Set the `properties.policies.softDeletePolicy.status` property to `enabled`.

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

### Configure with Azure CLI

```bash
az acr config soft-delete update -r '<name>' --days 90 --status enabled
```

## LINKS

- [Data Management for Reliability](https://learn.microsoft.com/azure/architecture/framework/resiliency/data-management)
- [Azure Container Registry (ACR) soft delete policy](https://learn.microsoft.com/azure/container-registry/container-registry-soft-delete-policy)
- [Azure Container Registry service tiers](https://learn.microsoft.com/azure/container-registry/container-registry-skus)
- [Policy for untagged manifests](https://learn.microsoft.com/azure/container-registry/container-registry-retention-policy)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)
