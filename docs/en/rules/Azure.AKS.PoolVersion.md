---
severity: Important
pillar: Reliability
category: Design
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.PoolVersion/
---

# Upgrade AKS node pool version

## SYNOPSIS

AKS node pools should match Kubernetes control plane version.

## DESCRIPTION

AKS supports multiple node pools.
In a multi-node pool configuration, it is possible that the control plane and node pools could be running a different version of Kubernetes.

Different versions of Kubernetes between the control plane and node pools is intended as a short term option to allow rolling upgrades.
For general operation, the control plane and node pool Kubernetes versions should match.

## RECOMMENDATION

Consider upgrading node pools to match AKS control plan version.

## LINKS

- [Target and non-functional requirements](https://learn.microsoft.com/azure/architecture/framework/resiliency/design-requirements#meet-application-platform-requirements)
- [Upgrade a cluster control plane with multiple node pools](https://learn.microsoft.com/azure/aks/use-multiple-node-pools#upgrade-a-cluster-control-plane-with-multiple-node-pools)
- [Supported Kubernetes versions in Azure Kubernetes Service](https://learn.microsoft.com/azure/aks/supported-kubernetes-versions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)
