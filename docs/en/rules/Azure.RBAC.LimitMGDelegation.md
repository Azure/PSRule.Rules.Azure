---
severity: Important
pillar: Security
category: Identity and access management
resource: Subscription
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.RBAC.LimitMGDelegation/
ms-content-id: 0f0a1cc8-9528-46b7-8f31-b9fe76cc0d66
---

# Limit Management Group delegation

## SYNOPSIS

Limit Role-Base Access Control (RBAC) inheritance from Management Groups.

## DESCRIPTION

RBAC in Azure inherits from management group to subscription to resource group to resource.
Management group RBAC assignments have broad impact.

## RECOMMENDATION

Consider limiting the number of assignment inherited from Management Groups by scoping permission to individual Resource Group.

Azure Blueprints can be used to rollout standard RBAC assignments to common resources.
Additionally RBAC assignments can be deployed using Azure Resource Manager templates.
