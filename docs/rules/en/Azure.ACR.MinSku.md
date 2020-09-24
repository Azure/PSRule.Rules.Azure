---
severity: Important
pillar: Operational Excellence
category: Deployment
resource: Container Registry
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.ACR.MinSku.md
ms-content-id: a70d16d4-3717-4eef-b588-8a0204860d6e
---

# Use ACR production SKU

## SYNOPSIS

ACR should use the Premium or Standard SKU for production deployments.

## DESCRIPTION

ACR should use the Premium or Standard SKU for production deployments.

## RECOMMENDATION

Use a minimum of Standard for production container registries.
Basic container registries are only recommended for non-production deployments.

Consider upgrading ACR to Premium and enabling geo-replication between Azure regions to provide an in region registry to complement high availability or disaster recovery for container environments.

## LINKS

- [Azure Container Registry SKUs](https://docs.microsoft.com/azure/container-registry/container-registry-skus)
- [Geo-replication in Azure Container Registry](https://docs.microsoft.com/azure/container-registry/container-registry-geo-replication)
- [Best practices for Azure Container Registry](https://docs.microsoft.com/azure/container-registry/container-registry-best-practices#geo-replicate-multi-region-deployments)
