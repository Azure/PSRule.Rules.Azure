---
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.AnonymousAccess/
---

# Container registry anonymous pull access is enabled

## SYNOPSIS

Anonymous pull access allows unidentified downloading of images and metadata from a container registry.

## DESCRIPTION

By default, Azure Container Registry (ACR) requires you to be authorized before you push or pull content from the registry.
When _anonymous pull access_ is enabled:

- Any client with network access can pull content from the entire registry without authorization.
- Repository-scoped tokens can not be used to limit pull access, tokens will be able to pull all content.

## RECOMMENDATION

Consider disabling anonymous pull access in scenarios that require user authentication.

## EXAMPLES

### Configure with Azure template

To deploy registries that pass this rule:

- Set the `properties.anonymousPullEnabled` property to `false`.

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
    "anonymousPullEnabled": false,
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

- Set the `properties.anonymousPullEnabled` property to `false`.

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
    anonymousPullEnabled: false
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

<!-- external:avm avm/res/container-registry/registry:0.5.1 anonymousPullEnabled -->

### Configure with Azure CLI

To configure registries that pass this rule:

```bash
az acr update  -n '<name>' -g '<resource_group>' --anonymous-pull-enabled false
```

## NOTES

The anonymous pull access feature is currently in preview.
Anonymous pull access is only available in the `Standard` and `Premium` service tiers.

This rule may generate false positives in specific scenarios where to intend to distribute OCI content to Internet users,
for example: You are a software vendor and intend to distribute container images of your software to customers.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [Make your container registry content publicly available](https://learn.microsoft.com/azure/container-registry/anonymous-pull-access)
- [Azure security baseline for Container Registry](https://learn.microsoft.com/security/benchmark/azure/baselines/container-registry-security-baseline)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/container-registry-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries#registryproperties)
