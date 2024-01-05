---
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.ManagedIdentity/
---

# Use managed identities for AKS cluster authentication

## SYNOPSIS

Configure AKS clusters to use managed identities for managing cluster infrastructure.

## DESCRIPTION

During the lifecycle of an AKS cluster, the control plane configures a number of Azure resources.
This includes node pools, networking, storage and other supporting services.

When making calls against the Azure REST APIs, an identity must be used to authenticate requests.
The type of identity the control plane will use is configurable at cluster creation.
Either a service principal or system-assigned managed identity can be used.

By default, the service principal credentials are valid for one year.
Service principal credentials must be rotated before expiry to prevent issues.
You can update or rotate the service principal credentials at any time.

Using a system-assigned managed identity abstracts the process of managing a service principal.
The managed identity is automatically created/ removed with the cluster.
Managed identities also reduce maintenance (and improve security) by automatically rotating credentials.

Separately, applications within an AKS cluster may use managed identities with AAD Pod Identity.

## RECOMMENDATION

Consider using managed identities during AKS cluster creation.
Additionally, consider redeploying the AKS cluster with managed identities instead of service principals.

## NOTES

AKS clusters can not be updated to use managed identities for cluster infrastructure after deployment.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access#resource-identity)
- [What are managed identities for Azure resources?](https://learn.microsoft.com/entra/identity/managed-identities-azure-resources/overview)
- [Use managed identities in Azure Kubernetes Service](https://learn.microsoft.com/azure/aks/use-managed-identity)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)
