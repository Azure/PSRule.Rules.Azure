---
severity: Important
pillar: Security
category: General
resource: Azure Kubernetes Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AKS.PodSecurityPolicy.md
---

# AKS cluster use Pod Security Policies

## SYNOPSIS

Configure AKS non-production clusters to use Pod Security Policies (Preview).

## DESCRIPTION

Pod Security Polices are a preview feature that can be enabled on AKS clusters after configuration.
Pod Security Polices limit pods from requesting or performing some privileged actions.
Based on the policy the pod specification may be updated with additional controls or blocked completely.

Configure Pod Security Policies first, before enabling the feature.
Enabling the feature before configuring Pod Security Polices, will block pod creation.

## RECOMMENDATION

Consider deploying AKS clusters, configuring Pod Security Polices then enabling on non-production clusters.
Only enable Pod Security Policies after configuring policies.

Pod Security Policies are currently in preview.

## LINK

- [Secure your cluster using pod security policies in Azure Kubernetes Service (AKS)](https://docs.microsoft.com/en-us/azure/aks/use-pod-security-policies)
- [Pod Security Policies](https://kubernetes.io/docs/concepts/policy/pod-security-policy/)
