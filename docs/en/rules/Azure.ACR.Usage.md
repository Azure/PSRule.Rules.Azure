---
reviewed: 2022/01/22
severity: Important
pillar: Cost Optimization
category: Reports
resource: Container Registry
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ACR.Usage/
---

# Container registry storage usage

## SYNOPSIS

Regularly remove deprecated and unneeded images to reduce storage usage.

## DESCRIPTION

Each ACR SKU has an amount of included storage.
When the amount of included storage is exceeded, additional storage costs per GiB are accrued.

It is good practice to regularly clean-up orphaned (or _dangling_) images.
These images are a result of pushing updated images with the same tag.

## RECOMMENDATION

Consider removing deprecated and unneeded images to reduce storage consumption.
Also consider upgrading to the Premium SKU for Basic or Standard registries to increase included storage.

## NOTES

This rule applies when analyzing resources deployed (in-flight) to Azure.

## LINKS

- [Generate cost reports](https://learn.microsoft.com/azure/architecture/framework/cost/monitor-reports)
- [Azure Container Registry service tiers](https://docs.microsoft.com/azure/container-registry/container-registry-skus)
- [Scalable storage](https://docs.microsoft.com/azure/container-registry/container-registry-storage#scalable-storage)
- [Manage registry size](https://docs.microsoft.com/azure/container-registry/container-registry-best-practices#manage-registry-size)
- [Delete container images in Azure Container Registry using the Azure CLI](https://docs.microsoft.com/azure/container-registry/container-registry-delete)
