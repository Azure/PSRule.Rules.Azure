---
severity: Important
category: Security configuration
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.AKS.UseRBAC.md
---

# Azure.AKS.UseRBAC

## Synopsis

AKS cluster should use role-based access control (RBAC).

## Recommendation

Azure AD integration with AKS provides granular access control for Kubernetes resources using RBAC.

RBAC is a deployment time configuration. Consider redeploying the AKS cluster with RBAC enabled.
