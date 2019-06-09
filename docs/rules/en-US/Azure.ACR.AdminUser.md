---
severity: Critical
category: Security configuration
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.ACR.AdminUser.md
---

# Azure.ACR.AdminUser

## SYNOPSIS

Use RBAC for delegating access to ACR instead of the registry admin user.

## DESCRIPTION

Use RBAC for delegating access to ACR instead of the registry admin user.

## RECOMMENDATION

The Admin user account is a single user account with administrative access to the registry. This account is designed for single user access for test and development.

Consider using an AAD-based identity with roles based access granted. Also consider disabling the Admin user account.
