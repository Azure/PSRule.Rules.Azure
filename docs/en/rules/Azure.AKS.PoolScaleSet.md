---
severity: Important
pillar: Performance Efficiency
category: Capacity planning
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.PoolScaleSet/
---

# AKS clusters use VM scale sets

## SYNOPSIS

Deploy AKS clusters with nodes pools based on VM scale sets.

## DESCRIPTION

When deploying AKS clusters, Azure node pool VMs can be deployed using Availability Sets or VM Scale Sets.
New AKS clusters default to VM scale set node pools.

Deploying AKS clusters with scale set node pools is required for some cluster features such as multiple node pools and cluster autoscaler.

## RECOMMENDATION

Multiple node pools and the cluster autoscaler can be used to improve the scalability and performance of a cluster while minimizing cost.

Using VM scale sets is a deployment time configuration.
Consider redeploying the AKS cluster with VM Scale Sets instead of Availability Sets.

## LINKS

- [Create and manage multiple node pools for a cluster in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/azure/aks/use-multiple-node-pools)
- [Cluster autoscaler](https://docs.microsoft.com/azure/aks/concepts-scale#cluster-autoscaler)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)
