---
severity: Important
category: Performance
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.ACR.MinSku.md
---

# Azure.ACR.MinSku

## SYNOPSIS

ACR should use the Premium or Standard SKU for production deployments.

## DESCRIPTION

ACR should use the Premium or Standard SKU for production deployments.

## RECOMMENDATION

Use a minimum of Standard for production container registries. Basic container registries are only recommended for non-production deployments.

Consider upgrading ACR to Premium and enabling geo-replication between Azure regions to provide an in region registry to complement high availability or disaster recovery for container environments.
