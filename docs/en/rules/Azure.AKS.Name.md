---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Azure Kubernetes Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AKS.Name/
---

# Use valid AKS cluster names

## SYNOPSIS

Azure Kubernetes Service (AKS) cluster names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for AKS cluster names are:

- Between 1 and 63 characters long.
- Alphanumerics, underscores, and hyphens.
- Start and end with alphanumeric.
- Cluster names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet AKS cluster naming requirements.
Additionally consider naming resources with a standard naming convention.

## NOTES

This rule does not check if cluster names are unique.

Cluster DNS prefix has different naming requirements then cluster name.
The requirements for DNS prefixes are:

- Between 1 and 54 characters long.
- Alphanumerics and hyphens.
- Start and end with alphanumeric.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Recommended abbreviations for Azure resource types](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.containerservice/managedclusters)
