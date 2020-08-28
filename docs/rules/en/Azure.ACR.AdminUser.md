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

Use Azure AD accounts instead of using the registry admin user.

## DESCRIPTION

Use role-based access control (RBAC) for delegating an Azure AD (AAD) account access to Azure Container Registry (ACR) instead of using the registry admin user.

## RECOMMENDATION

The Admin user account is a single user account with administrative access to the registry.
This account provides single user access for test and development.

Consider using an AAD-based identity with roles based access granted.
Also consider disabling the Admin user account.

## LINKS

- [Authenticate with a private Docker container registry](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-authentication)
- [Best practices for Azure Container Registry](https://docs.microsoft.com/en-us/azure/container-registry/container-registry-best-practices#authentication)
