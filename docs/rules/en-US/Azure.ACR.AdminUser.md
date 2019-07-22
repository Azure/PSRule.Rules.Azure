---
severity: Critical
category: Security configuration
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.ACR.AdminUser.md
ms-content-id: bbf194a7-6ca3-4b1d-9170-6217eb26620d
---

# Azure.ACR.AdminUser

## SYNOPSIS

Use Azure AD accounts instead of using the registry admin user.

## DESCRIPTION

Use role-based access control (RBAC) for delegating an Azure AD (AAD) account access to Azure Container Registry (ACR) instead of using the registry admin user.

## RECOMMENDATION

The Admin user account is a single user account with administrative access to the registry. This account provides single user access for test and development.

Consider using an AAD-based identity with roles based access granted. Also consider disabling the Admin user account.
