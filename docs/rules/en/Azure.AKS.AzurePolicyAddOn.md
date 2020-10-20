---
severity: Important
pillar: Security
category: General
resource: Azure Kubernetes Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AKS.AzurePolicyAddOn.md
---

# Use Azure Policy Add-on with AKS clusters

## SYNOPSIS

Configure Azure Kubernetes Service (AKS) clusters to use Azure Policy Add-on for Kubernetes.

## DESCRIPTION

AKS clusters support integration with Azure Policy using an Open Policy Agent (OPA).
Azure Policy integration is provided by an optional add-on that can be enabled on AKS clusters.
Once enabled and Azure policies assigned, AKS clusters will enforce the configured constraints.

Examples of policies include:

- Enforce HTTPS ingress in Kubernetes cluster.
- Do not allow privileged containers in Kubernetes cluster.
- Ensure container CPU and memory resource limits do not exceed the specified limits in Kubernetes cluster.

## RECOMMENDATION

Consider installing the Azure Policy Add-on for AKS clusters.
Additionally, assign one or more Azure Policy definitions to security controls.

## NOTES

Azure Policy for AKS clusters is generally available (GA).
Azure Policy for AKS Engine and Arc enabled Kubernetes are currently in preview.

## LINKS

- [Understand Azure Policy for Kubernetes clusters](https://docs.microsoft.com/azure/governance/policy/concepts/policy-for-kubernetes)
- [Overview of securing pods with Azure Policy for AKS](https://docs.microsoft.com/azure/aks/use-pod-security-on-azure-policy)
