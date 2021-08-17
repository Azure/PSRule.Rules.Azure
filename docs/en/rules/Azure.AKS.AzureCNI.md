---
severity: Important
pillar: Operational Excellence
category: Capacity planning
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.AzureCNI/
---

# AKS clusters using Azure CNI should use large subnets

## SYNOPSIS

AKS clusters using Azure CNI should use large subnets to reduce IP exhaustion issues.

## DESCRIPTION

In addition to kubenet, AKS clusters support Azure Container Networking Interface (CNI). This enables every pod to be accessed directly from the subnet via an IP address. Each node supports a maximum number of pods, which are reserved as IP addresses. This approach requires more capacity planning ahead of time, and can result to IP address exhaustion or the need to rebuild AKS clusters into a larget subnet as application workloads begin to grow.

## RECOMMENDATION

Consider allocating a large subnet(/23 or bigger) to your AKS cluster.

## NOTES

This rule applies when analyzing resources deployed to Azure.

## LINKS

- [Configure Azure CNI networking in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/azure/aks/configure-azure-cni)
- [Use kubenet networking with your own IP address ranges in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/azure/aks/configure-kubenet)
- [Tutorial: Configure Azure CNI networking in Azure Kubernetes Service (AKS) using Ansible](https://docs.microsoft.com/azure/developer/ansible/aks-configure-cni-networking?tabs=ansible)