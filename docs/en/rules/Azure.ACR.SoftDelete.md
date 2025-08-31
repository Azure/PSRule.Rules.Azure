---
severity: Important
pillar: Reliability
category: RE:04 Target metrics
resource: Container Registry
resourceType: Microsoft.ContainerRegistry/registries
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.SoftDelete/
---

# Container Registry soft delete policy is not enabled

## SYNOPSIS

Container registry artifacts are permanently lost when accidentally deleted without soft delete protection.

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

### Configure with Bicep

To deploy an Azure Container Registry that pass this rule:

- Set the `properties.policies.softDeletePolicy.status` property to `enabled`.

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

<!-- external:avm avm/res/container-registry/registry softDeletePolicyStatus -->

### Configure with Azure template

To deploy an Azure Container Registry that pass this rule:

- Set the `properties.policies.softDeletePolicy.status` property to `enabled`.

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

### Configure with Azure CLI

```bash
az acr config soft-delete update -r '<name>' --days 90 --status enabled
```

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Azure Container Registry (ACR) soft delete policy](https://learn.microsoft.com/azure/container-registry/container-registry-soft-delete-policy)
- [Azure Container Registry service tiers](https://learn.microsoft.com/azure/container-registry/container-registry-skus)
- [Policy for untagged manifests](https://learn.microsoft.com/azure/container-registry/container-registry-retention-policy)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)
