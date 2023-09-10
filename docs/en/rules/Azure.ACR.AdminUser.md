---
reviewed: 2023-06-09
severity: Critical
pillar: Security
category: Authentication
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.AdminUser/
ms-content-id: bbf194a7-6ca3-4b1d-9170-6217eb26620d
---

# Disable ACR admin user

## SYNOPSIS

Use Azure AD identities instead of using the registry admin user.

## DESCRIPTION

Azure Container Registry (ACR) includes a built-in admin user account.
The admin user account is a single user account with administrative access to the registry.
This account provides single user access for early test and development.
The admin user account is not intended for use with production container registries.

Instead use role-based access control (RBAC).
RBAC can be used to delegate registry permissions to an Azure AD (AAD) identity.

## RECOMMENDATION

Consider disabling the admin user account and only use identity-based authentication for registry operations.

## EXAMPLES

### Configure with Azure template

To deploy Container Registries that pass this rule:

- Set `properties.adminUserEnabled` to `false`.

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

To deploy Container Registries that pass this rule:

- Set `properties.adminUserEnabled` to `false`.

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
az acr update --admin-enabled false -n '<name>' -g '<resource_group>'
```

### Configure with Azure PowerShell

```powershell
Update-AzContainerRegistry -ResourceGroupName '<resource_group>' -Name '<name>' -DisableAdminUser
```

## LINKS

- [Use identity-based authentication](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication#use-identity-based-authentication)
- [Authenticate with a private Docker container registry](https://learn.microsoft.com/azure/container-registry/container-registry-authentication)
- [Best practices for Azure Container Registry](https://learn.microsoft.com/azure/container-registry/container-registry-best-practices#authentication-and-authorization)
- [Use an Azure managed identity to authenticate to an Azure container registry](https://learn.microsoft.com/azure/container-registry/container-registry-authentication-managed-identity)
- [Azure Container Registry roles and permissions](https://learn.microsoft.com/azure/container-registry/container-registry-roles)
- [What is Azure role-based access control (Azure RBAC)?](https://learn.microsoft.com/azure/role-based-access-control/overview)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/container-registry-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [IM-3: Manage application identities securely and automatically](https://learn.microsoft.com/security/benchmark/azure/baselines/container-registry-security-baseline#im-3-manage-application-identities-securely-and-automatically)
- [PA-1: Separate and limit highly privileged/administrative users](https://learn.microsoft.com/security/benchmark/azure/baselines/container-registry-security-baseline#pa-1-separate-and-limit-highly-privilegedadministrative-users)
- [Azure Policy Regulatory Compliance controls for Azure Container Registry](https://learn.microsoft.com/azure/container-registry/security-controls-policy)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerregistry/registries)
