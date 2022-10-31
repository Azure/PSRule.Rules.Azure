---
severity: Important
pillar: Security
category: Data protection
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.ContentTrust/
---

# Use trusted container images

## SYNOPSIS

Use container images signed by a trusted image publisher.

## DESCRIPTION

Azure Container Registry (ACR) content trust enables pushing and pulling of signed images.
Signed images provides additional assurance that they have been built on a trusted source.

To enable content trust, the container registry must be using a Premium SKU.

Content trust is currently not supported in a registry that's encrypted with a customer-managed key.
When using customer-managed keys, content trust can not be enabled.

## RECOMMENDATION

Consider enabling content trust on registries, clients, and sign container images.

## EXAMPLES

### Configure with Azure template

To deploy Container Registries that pass this rule:

- Set `properties.trustPolicy.status` to `enabled`.
- Set `properties.trustPolicy.type` to `Notary`.

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

- Set `properties.trustPolicy.status` to `enabled`.
- Set `properties.trustPolicy.type` to `Notary`.

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

## LINKS

- [Follow best practices for container security](https://learn.microsoft.com/azure/architecture/framework/security/applications-services#follow-best-practices-for-container-security)
- [Content trust in Azure Container Registry](https://learn.microsoft.com/azure/container-registry/container-registry-content-trust)
- [Content trust in Docker](https://docs.docker.com/engine/security/trust/content_trust/)
- [Overview of customer-managed keys](https://learn.microsoft.com/azure/container-registry/tutorial-customer-managed-keys#before-you-enable-a-customer-managed-key)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)
