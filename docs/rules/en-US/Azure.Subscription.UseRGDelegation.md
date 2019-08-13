---
severity: Important
category: Security operations
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.Subscription.UseRGDelegation.md
---

# Use Resource Group delegation

## SYNOPSIS

Use RBAC assignments on resource groups instead of individual resources.

## DESCRIPTION

Azure provides a flexible delegation model using RBAC that allows administrators to grant fine grained permissions using roles to Azure resources. Permissions can be scoped to management group, subscription, resource group or individual resources.

## RECOMMENDATION

Consider using RBAC assignments on resource groups instead of individual resources.
