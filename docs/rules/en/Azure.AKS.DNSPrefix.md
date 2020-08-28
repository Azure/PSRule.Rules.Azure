---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: Azure Kubernetes Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AKS.DNSPrefix.md
---

# Use valid AKS cluster DNS prefix

## SYNOPSIS

Azure Kubernetes Service (AKS) cluster DNS prefix should meet naming requirements.

## DESCRIPTION

The DNS prefix for AKS clusters has different requirements then the cluster name.
The requirements for DNS prefixes are:

- Between 1 and 54 characters long.
- Alphanumerics and hyphens.
- Start and end with alphanumeric.

## RECOMMENDATION

Consider using a DNS prefix that meets naming requirements.
