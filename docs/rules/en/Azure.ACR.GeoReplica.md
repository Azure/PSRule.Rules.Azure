---
severity: Important
pillar: Reliability
category: Data management
resource: Container Registry
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.ACR.GeoReplica.md
---

# Geo-replicate container images

## SYNOPSIS

Use geo-replicated container registries to compliment a multi-region container deployments.

## DESCRIPTION

A container registry is stored and maintained by default in a single region.
Optionally geo-replication to one or more additional regions can be enabled.

Geo-replicating container registries provides the following benefits:

- Single registry/ image/ tag names can be used across multiple regions.
- Network-close registry access within the region reduces latency.
- As images are pulled from a local replicated registry, each pull does not incur additional egress costs.

## RECOMMENDATION

Consider using a geo-replicated container registry for multi-region deployments.

## NOTES

This rule applies when analyzing resources deployed to Azure.

## LINKS

- [Geo-replicate multi-region deployments](https://docs.microsoft.com/azure/container-registry/container-registry-best-practices#geo-replicate-multi-region-deployments)
- [Geo-replication in Azure Container Registry](https://docs.microsoft.com/azure/container-registry/container-registry-geo-replication)
- [Tutorial: Prepare a geo-replicated Azure container registry](https://docs.microsoft.com/azure/container-registry/container-registry-tutorial-prepare-registry)
