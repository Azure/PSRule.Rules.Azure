---
severity: Important
pillar: Performance Efficiency
category: Capacity planning
resource: Azure Kubernetes Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AKS.StandardLB.md
---

# Use the Standard load balancer SKU

## SYNOPSIS

Azure Kubernetes Clusters (AKS) should use a Standard load balancer SKU.

## DESCRIPTION

When deploying an AKS cluster, either a Standard or Basic load balancer SKU can be configured.
A Standard load balancer SKU is required for several AKS features including:

- Multiple node pools
- Availability zones
- Authorized IP ranges

These features improve the scalability and reliability of the cluster.

## RECOMMENDATION

Consider using Standard load balancer SKU during AKS cluster creation.
Additionally, consider redeploying the AKS clusters with a Standard load balancer SKU configured.

## NOTES

AKS clusters can not be updated to use a Standard load balancer SKU after deployment.

## LINKS

- [Use a Standard SKU load balancer in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/load-balancer-standard)
- [Azure template reference](https://docs.microsoft.com/en-us/azure/templates/microsoft.containerservice/managedclusters#containerservicenetworkprofile-object)
