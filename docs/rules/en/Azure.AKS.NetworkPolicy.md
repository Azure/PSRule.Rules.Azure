---
severity: Important
pillar: Security
category: Network security and containment
resource: Azure Kubernetes Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AKS.NetworkPolicy.md
---

# AKS clusters use Azure Network Policies

## SYNOPSIS

Deploy AKS clusters with Azure Network Policies enabled.

## DESCRIPTION

By default, all pods in an AKS cluster can send and receive traffic without limitations.
Network Policy defines access policies for limiting network communication of Pods.

For improved security, define network policy rules to control the flow of traffic.
For example, only permit backend components to receive traffic from frontend components.

To use Network Policy it must be enabled at cluster deployment time.
AKS supports two implementations of network policies, Azure Network Policies and Calico Network Policies.
Azure Network Policies are supported by Azure support and engineering teams.

## RECOMMENDATION

Azure Network Policies improve cluster and workload security by limiting network communication.

Network Policy is a deployment time configuration.
Consider redeploying the AKS cluster with Network Policy enabled.

## LINKS

- [Secure traffic between pods using network policies in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/use-network-policies)
- [Best practices for network connectivity and security in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/operator-best-practices-network#control-traffic-flow-with-network-policies)
- [Network Policies](https://kubernetes.io/docs/concepts/services-networking/network-policies/)
