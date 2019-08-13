---
severity: Important
category: Security operations
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.Subscription.LimitMGDelegation.md
---

# Limit Management Group delegation

## SYNOPSIS

Limit Role-Base Access Control (RBAC) inheritance from Management Groups.

## DESCRIPTION

RBAC in Azure inherits from management group to subscription to resource group to resource. Management group RBAC assignments have broad impact.

## RECOMMENDATION

Consider limiting the number of assignment inherited from Management Groups by scoping permission to individual Resource Group.

Azure Blueprints can be used to rollout standard RBAC assignments to common resources. Additionally RBAC assignments can be deployed using Azure Resource Manager templates.
