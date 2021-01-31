---
severity: Critical
pillar: Security
category: Identity and access management
resource: Container Registry
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.ACR.AdminUser.md
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

Consider disabling the admin user account and only using AAD-based identities for registry operations.

## EXAMPLES

### Configure with Azure CLI

```bash
az acr update --admin-enabled false -n '<name>' -g '<resource_group>'
```

### Configure with Azure PowerShell

```powershell
Update-AzContainerRegistry -ResourceGroupName '<resource_group>' -Name '<name>' -DisableAdminUser
```

## LINKS

- [Authenticate with a private Docker container registry](https://docs.microsoft.com/azure/container-registry/container-registry-authentication)
- [Best practices for Azure Container Registry](https://docs.microsoft.com/azure/container-registry/container-registry-best-practices#authentication)
- [Use role-based access control (RBAC)](https://docs.microsoft.com/azure/architecture/framework/security/design-identity#use-role-based-access-control-rbac)
- [Azure Container Registry authentication with service principals](https://docs.microsoft.com/azure/container-registry/container-registry-auth-service-principal)
- [Use an Azure managed identity to authenticate to an Azure container registry](https://docs.microsoft.com/azure/container-registry/container-registry-authentication-managed-identity)
- [Azure Container Registry roles and permissions](https://docs.microsoft.com/azure/container-registry/container-registry-roles)
- [What is Azure role-based access control (Azure RBAC)?](https://docs.microsoft.com/azure/role-based-access-control/overview)
