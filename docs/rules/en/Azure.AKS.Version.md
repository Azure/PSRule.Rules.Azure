---
severity: Important
pillar: Operational Excellence
category: Deployment
resource: Azure Kubernetes Service
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AKS.Version.md
ms-content-id: b0bd4e66-af2f-4d0a-82ae-e4738418bb7e
---

# Upgrade Kubernetes version

## SYNOPSIS

AKS control plane and nodes pools should use a current stable release.

## DESCRIPTION

The AKS support policy for Kubernetes is include N-2 stable minor releases.
Additionally two patch releases for each minor version are supported.

A list of available Kubernetes versions can be found using the `az aks get-versions -o table --location <location>` CLI command.

## RECOMMENDATION

Consider upgrading AKS control plane and nodes pools to the latest stable version of Kubernetes.

## NOTES

To configure this rule:

- Override the `Azure_AKSMinimumVersion` configuration value with the minimum Kubernetes version.

## LINKS

- [Supported Kubernetes versions in Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions)
- [Support policies for Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/support-policies)
- [Azure template reference](https://docs.microsoft.com/en-us/azure/templates/microsoft.containerservice/managedclusters)
