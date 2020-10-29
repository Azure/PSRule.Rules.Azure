---
severity: Important
pillar: Cost Optimization
category: Resource usage
resource: Container Registry
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.ACR.Usage.md
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

This rule applies when analyzing resources deployed to Azure.

## LINKS

- [Azure Container Registry service tiers](https://docs.microsoft.com/azure/container-registry/container-registry-skus)
- [Scalable storage](https://docs.microsoft.com/azure/container-registry/container-registry-storage#scalable-storage)
- [Manage registry size](https://docs.microsoft.com/azure/container-registry/container-registry-best-practices#manage-registry-size)
- [Delete container images in Azure Container Registry using the Azure CLI](https://docs.microsoft.com/azure/container-registry/container-registry-delete)
