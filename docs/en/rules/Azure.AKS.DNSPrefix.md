---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.DNSPrefix/
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

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Recommended abbreviations for Azure resource types](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)
