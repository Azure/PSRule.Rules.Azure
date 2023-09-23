---
severity: Important
pillar: Security
category: Identity and access management
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.AnonymousAccess/
---

# Anonymous pull access

## SYNOPSIS

Disable anonymous pull access.

## DESCRIPTION

Azure Container Registry (ACR) allows you to pull or push content from an Azure container registry by being authenticated.
However, it is possible to pull content from an Azure container registry by being unauthenticated (anonymous pull access).

By default, access to pull or push content from an Azure container registry is only available to authenticated users.

Generally speaking it is not a good practice to allow data-plane operations to unauthenticated users.
However, anonymous pull access can be used in scenarios that do not require user authentication such as distributing public container images.

## RECOMMENDATION

Consider disabling anonymous pull access in scenarios that require user authentication.

## EXAMPLES

### Configure with Azure template

To deploy Azure Container Registries that pass this rule:

- Set the `properties.anonymousPullEnabled` property to `false`.

For example:

```json
{
  "type": "Microsoft.ContainerRegistry/registries",
  "apiVersion": "2023-01-01-preview",
  "name": "[parameters('registryName')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard"
  },
  "properties": {
    "anonymousPullEnabled": false
  }
}
```

### Configure with Bicep

To deploy Azure Container Registries that pass this rule:

- Set the `properties.anonymousPullEnabled` property to `false`.

For example:

```bicep
resource acr 'Microsoft.ContainerRegistry/registries@2023-01-01-preview' = {
  name: registryName
  location: location
  sku: {
    name: 'Standard'
  }
  properties: {
    anonymousPullEnabled: false
  }
}
```

### Configure with Azure CLI

```bash
az acr update --name myregistry --anonymous-pull-enabled false
```

## NOTES

The anonymous pull access feature is currently in preview.
Anonymous pull access is only available in the `Standard` and `Premium` service tiers.

## LINKS

- [Authentication with Azure AD](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication)
- [Make your container registry content publicly available](https://learn.microsoft.com/azure/container-registry/anonymous-pull-access)
- [Azure security baseline for Container Registry](https://learn.microsoft.com/security/benchmark/azure/baselines/container-registry-security-baseline)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/container-registry-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Azure deployment reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.containerregistry/registries#registryproperties)
