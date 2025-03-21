---
severity: Awareness
pillar: Security
category: SE:08 Hardening resources
resource: API Management
resourceType: Microsoft.ApiManagement/service,Microsoft.ApiManagement/service/products
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.SampleProducts/
---

# API Management Service has default products present

## SYNOPSIS

API Management Services with default products configured may expose more APIs than intended.

## DESCRIPTION

API Management includes two sample products _Starter_ and _Unlimited_.
These products are created by default when an API Management Service using V1 plans is created.

In both cases, these products are created with a default set of developer permissions that may be too permissive.
Accidentally adding APIs to these sample products may expose API metadata to unauthorized users.

Before publishing APIs, plan access control for API development and usage.
Additional products or workspaces can be created to manage discovery of APIs and enforce usage policies.

## RECOMMENDATION

Consider removing starter and unlimited products from API Management to reduce the risk of unauthorized API discovery.

## NOTES

This rule applies when analyzing API Management Services (in-flight) and running within Azure.

## LINKS

- [SE:08 Hardening resources](https://learn.microsoft.com/azure/well-architected/security/harden-resources)
- [Create and publish a product](https://learn.microsoft.com/azure/api-management/api-management-howto-add-products)
