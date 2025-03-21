---
severity: Important
pillar: Security
category: Identity and access management
resource: Azure Kubernetes Service
resourceType: Microsoft.ContainerService/managedClusters
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.UseRBAC/
ms-content-id: 61ff3a23-9bfd-4e91-8959-798b43237775
---

# AKS clusters use RBAC

## SYNOPSIS

Deploy AKS cluster with role-based access control (RBAC) enabled.

## DESCRIPTION

AKS supports granting access to cluster resources using role-based access control (RBAC).
Additionally Azure Active Directory (AAD) integration with AKS allows, RBAC to be granted based on AAD user or group.

## RECOMMENDATION

Azure AD integration with AKS provides granular access control for Kubernetes resources using RBAC.

RBAC is a deployment time configuration.
Consider redeploying the AKS cluster with RBAC enabled.

## LINKS

- [Access and identity options for Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/concepts-identity#azure-ad-integration)
- [Authorization with Azure AD](https://learn.microsoft.com/azure/architecture/framework/security/design-identity-authorization)
- [Best practices for authentication and authorization in Azure Kubernetes Service (AKS)](https://learn.microsoft.com/azure/aks/operator-best-practices-identity#use-azure-active-directory)
- [Using RBAC Authorization](https://kubernetes.io/docs/reference/access-authn-authz/rbac/)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters#managedclusterproperties-object)
- [Use role-based access control (RBAC)](https://learn.microsoft.com/azure/architecture/framework/security/design-identity#use-role-based-access-control-rbac)
