---
severity: Important
pillar: Security
category: Identity and access management
resource: Subscription
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.RBAC.PIM.md
---

# Use JiT role activation with PIM

## SYNOPSIS

Use just-in-time (JiT) activation of roles instead of persistent role assignment.

## DESCRIPTION

PIM helps manage the impact of identity compromise or misuse of permissions by reducing persistent access.
With PIM, eligible identities can activate time-bound role assignments on an as needed basis (just-in-time).
Activation typically occurs before a schedule change or management operation.

PIM is an Azure Active Directory (AD) feature included in Azure AD Premium P2.

## RECOMMENDATION

Consider using Privileged Identity Management (PIM) to activate privileged roles on an as needed basis.

## LINKS

- [What is Azure AD Privileged Identity Management?](https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-configure)
- [Discover Azure resources to manage in Privileged Identity Management](https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-resource-roles-discover-resources)
- [Configure Azure resource role settings in Privileged Identity Management](https://docs.microsoft.com/en-us/azure/active-directory/privileged-identity-management/pim-resource-roles-configure-role-settings)
