---
severity: Important
category: Performance
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.ACR.MinSku.md
---

# Azure.ACR.MinSku

## Synopsis

ACR should use the Premium or Standard SKU for production deployments.

## Recommendation

Use a minimum of Standard for production container registries. Basic container registries are only recommended for non-production deployments.

Consider upgrading to premium to enable geo-replication between Azure regions to provide an in region registry to complement high availability or disaster recovery for container environments.
