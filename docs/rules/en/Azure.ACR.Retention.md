---
severity: Important
pillar: Cost Optimization
category: Resource usage
resource: Container Registry
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.ACR.Retention.md
---

# Configure ACR retention policies

## SYNOPSIS

Use a retention policy to cleanup untagged manifests.

## DESCRIPTION

Retention policy is a configurable option of Premium Azure Container Registry (ACR).
When a retention policy is configured, untagged manifests in the registry are automatically deleted.
A manifest is untagged when a more recent image is pushed using the same tag. i.e. latest.

The retention policy (in days) can be set to 0-365.
The default is 7 days.

## RECOMMENDATION

Consider enabling a retention policy for untagged manifests.

## NOTES

Retention policies for Azure Container Registry is currently in preview.

## LINKS

- [Scalable storage](https://docs.microsoft.com/azure/container-registry/container-registry-storage#scalable-storage)
- [Set a retention policy for untagged manifests](https://docs.microsoft.com/azure/container-registry/container-registry-retention-policy)
- [Lock a container image in an Azure container registry](https://docs.microsoft.com/azure/container-registry/container-registry-image-lock)
