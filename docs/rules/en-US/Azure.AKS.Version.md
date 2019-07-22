---
severity: Important
category: Operations management
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.AKS.Version.md
ms-content-id: b0bd4e66-af2f-4d0a-82ae-e4738418bb7e
---

# Azure.AKS.Version

## SYNOPSIS

AKS clusters should meet the minimum version.

## DESCRIPTION

The Kubernetes support policy for AKS includes four stable minor releases, and two patch releases for each minor version.

A list of available Kubernetes versions can be found using the `az aks get-versions -o table --location <location>` CLI command.

## RECOMMENDATION

Upgrade Kubernetes to the latest stable version of Kubernetes.

For more information see [Supported Kubernetes versions in Azure Kubernetes Service](https://docs.microsoft.com/en-us/azure/aks/supported-kubernetes-versions).
