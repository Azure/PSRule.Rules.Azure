---
severity: Important
pillar: Security
category: Identity and access management
resource: Subscription
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.RBAC.CoAdministrator/
---

# Use role-based access control

## SYNOPSIS

Delegate access to manage Azure resources using role-based access control (RBAC).

## DESCRIPTION

Use of Co-administrator is intended to support management of resources deployed using the Classic deployment model.
Resources deployed in the Resource Manager model do not require delegation of Co-administrators.

Azure RBAC provides greater flexibility and control providing over 100 built-in roles.
Additionally RBAC works with advanced advanced security features like Privileged Identity Management (PIM).

## RECOMMENDATION

Consider delegating access to manage Azure resources using RBAC instead of classic Co-administrator roles.
Limit delegation of Co-administrator roles only to subscription that contain resources deployed in the Classic deployment model.

## LINKS

- [Azure classic subscription administrators](https://learn.microsoft.com/azure/role-based-access-control/classic-administrators)
- [Classic subscription administrator roles, Azure RBAC roles, and Azure AD administrator roles](https://learn.microsoft.com/azure/role-based-access-control/rbac-and-directory-admin-roles)
- [What is Azure AD Privileged Identity Management?](https://learn.microsoft.com/azure/active-directory/privileged-identity-management/pim-configure)
