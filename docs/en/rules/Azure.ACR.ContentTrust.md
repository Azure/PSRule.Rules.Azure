---
reviewed: 2025-07-01
deprecated: true
severity: Important
pillar: Security
category: SE:02 Secured development lifecycle
resource: Container Registry
resourceType: Microsoft.ContainerRegistry/registries
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.ContentTrust/
---

# Container Registry Docker content trust is not enabled

## SYNOPSIS

Docker content trust allows images to be signed and verified when pulled from a container registry.

## DESCRIPTION

Azure Container Registry (ACR) content trust enables pushing and pulling of signed images.
Signed images provides additional assurance that they have been built on a trusted source.

To enable content trust, the container registry must be using a Premium SKU.

Content trust is currently not supported in a registry that's encrypted with a customer-managed key.
When using customer-managed keys, content trust can not be enabled.

<!-- deprecation:note v1.45.0
Content trust is replaced by OCI artifact signing, which is supported by Azure Container Registry.
-->

## RECOMMENDATION

Consider enabling content trust on registries, clients, and sign container images.

## EXAMPLES

### Configure with Azure template

To deploy registries that pass this rule:

- Set `properties.trustPolicy.status` to `enabled`.
- Set `properties.trustPolicy.type` to `Notary`.

For example:

```json
{
  "type": "Microsoft.ContainerRegistry/registries",
  "apiVersion": "2023-08-01-preview",
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
    "policies": {
      "trustPolicy": {
        "status": "enabled",
        "type": "Notary"
      },
      "retentionPolicy": {
        "days": 30,
        "status": "enabled"
      }
    }
  }
}
```

### Configure with Bicep

To deploy registries that pass this rule:

- Set `properties.trustPolicy.status` to `enabled`.
- Set `properties.trustPolicy.type` to `Notary`.

For example:

```bicep
resource registry 'Microsoft.ContainerRegistry/registries@2023-08-01-preview' = {
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
    policies: {
      trustPolicy: {
        status: 'enabled'
        type: 'Notary'
      }
      retentionPolicy: {
        days: 30
        status: 'enabled'
      }
    }
  }
}
```

<!-- external:avm avm/res/container-registry/registry:0.5.1 trustPolicyStatus -->

## NOTES

This rule is deprecated from v1.45.0.
By default, PSRule will not evaluate this rule unless explicitly enabled.
See https://aka.ms/ps-rule-azure/deprecations.

## LINKS

- [SE:02 Secured development lifecycle](https://learn.microsoft.com/azure/well-architected/security/secure-development-lifecycle)
- [Content trust in Azure Container Registry](https://learn.microsoft.com/azure/container-registry/container-registry-content-trust)
- [Content trust in Docker](https://docs.docker.com/engine/security/trust/content_trust/)
- [Overview of customer-managed keys](https://learn.microsoft.com/azure/container-registry/tutorial-customer-managed-keys#before-you-enable-a-customer-managed-key)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)
