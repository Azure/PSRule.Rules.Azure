---
severity: Important
pillar: Security
category: General
resource: Azure Kubernetes Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AKS.AzurePolicyAddOn.md
---

# Use Azure Policy add-on with AKS clusters

## SYNOPSIS

Configure Azure Kubernetes Cluster (AKS) clusters to use Azure Policy add-on for Kubernetes (Preview).

## DESCRIPTION

AKS clusters support integration with Azure Policy using an Open Policy Agent (OPA).
Azure Policy integration is provided by an optional add-on that can be enabled on AKS clusters.
Once enabled and Azure policies assigned, AKS clusters will enforce the configured constraints.

Examples of policies include:

- Enforce HTTPS ingress in Kubernetes cluster
- Do not allow privileged containers in Kubernetes cluster
- Ensure container CPU and memory resource limits do not exceed the specified limits in Kubernetes cluster

## RECOMMENDATION

Consider enabling the Azure Policy for Kubernetes integration on non-production AKS clusters.
Additionally, assign one or more Azure policy definitions to enforce.

## NOTES

Azure Policy for Kubernetes is currently in preview.

## LINKS

- [Understand Azure Policy for Kubernetes clusters](https://docs.microsoft.com/en-us/azure/governance/policy/concepts/policy-for-kubernetes)
