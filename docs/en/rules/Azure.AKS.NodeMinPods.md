---
severity: Important
pillar: Performance Efficiency
category: Capacity planning
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.NodeMinPods/
---

# Nodes use a minimum number of pods

## SYNOPSIS

Azure Kubernetes Cluster (AKS) nodes should use a minimum number of pods.

## DESCRIPTION

Node pools within a Azure Kubernetes Cluster (AKS) support between 30 and 250 pods per node.
The maximum number of pods for nodes within a node pool is set at deployment time.

When deploying AKS clusters with _kubernet_ networking the default maximum number of pods is 110.
For Azure CNI AKS clusters, the default maximum number of pods is 30.

In many environments, deploying DaemonSets for monitoring and management tools can exhaust the CNI default.

## RECOMMENDATION

Consider deploying node pools with a minimum number of pods per node.

## NOTES

By default, this rule fails when node pools have `maxPods` set to less than 50.

To configure this rule:

- Override the `Azure_AKSNodeMinimumMaxPods` configuration value with the minimum maxPods.

## LINKS

- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.containerservice/managedclusters/agentpools#ManagedClusterAgentPoolProfileProperties)
