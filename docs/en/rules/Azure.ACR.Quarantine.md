---
reviewed: 2021/11/13
severity: Important
pillar: Security
category: Azure resources
resource: Container Registry
preview: true
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.Quarantine/
---

# Use container image quarantine pattern

## SYNOPSIS

Enable container image quarantine, scan, and mark images as verified.

## DESCRIPTION

Image quarantine is a configurable option for Azure Container Registry (ACR).
When enabled, images pushed to the container registry are not available by default.
Each image must be verified and marked as `Passed` before it is available to pull.

To verify container images, integrate with an external security tool that supports this feature.

## RECOMMENDATION

Consider configuring a security tool to implement the image quarantine pattern.
Enable image quarantine on the container registry to ensure each image is verified before use.

## EXAMPLES

### Configure with Azure template

To deploy Container Registries that pass this rule:

- Set `properties.quarantinePolicy.status` to `enabled`.

For example:

```json
{
    "type": "Microsoft.ContainerRegistry/registries",
    "apiVersion": "2021-06-01-preview",
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
                "status": "enabled",
                "days": 30
            }
        }
    }
}
```

### Configure with Bicep

To deploy Container Registries that pass this rule:

- Set `properties.quarantinePolicy.status` to `enabled`.

For example:

```bicep
resource acr 'Microsoft.ContainerRegistry/registries@2021-06-01-preview' = {
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
        status: 'enabled'
        days: 30
      }
    }
  }
}
```

## NOTES

Image quarantine for Azure Container Registry is currently in preview.

## LINKS

- [Monitor Azure resources in Microsoft Defender for Cloud](https://docs.microsoft.com/azure/architecture/framework/security/monitor-resources#containers)
- [How do I enable automatic image quarantine for a registry?](https://docs.microsoft.com/azure/container-registry/container-registry-faq#how-do-i-enable-automatic-image-quarantine-for-a-registry-)
- [Quarantine Pattern](https://github.com/Azure/acr/tree/main/docs/preview/quarantine)
- [Secure the images and run time](https://docs.microsoft.com/azure/aks/operator-best-practices-container-image-management#secure-the-images-and-run-time)
