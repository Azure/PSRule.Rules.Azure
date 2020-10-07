---
severity: Important
pillar: Security
category: Identity and access management
resource: Subscription
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.RBAC.UseRGDelegation.md
ms-content-id: b31d32cc-1e9f-4ab8-93ab-1cd98354ad15
---

# Use Resource Group delegation

## SYNOPSIS

Use RBAC assignments on resource groups instead of individual resources.

## DESCRIPTION

Azure provides a flexible delegation model using RBAC that allows administrators to grant fine grained permissions using roles to Azure resources.
Permissions can be scoped to management group, subscription, resource group or individual resources.

## RECOMMENDATION

Consider using RBAC assignments on resource groups instead of individual resources.

## LINKS

- [Avoid granular and custom permissions](https://docs.microsoft.com/azure/architecture/framework/security/design-admins#avoid-granular-and-custom-permissions)
- [What is Azure role-based access control (Azure RBAC)?](https://docs.microsoft.com/azure/role-based-access-control/overview)
- [Best practices for Azure RBAC](https://docs.microsoft.com/azure/role-based-access-control/best-practices)
