---
severity: Awareness
pillar: Operational Excellence
category: Configuration
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.SampleProducts/
---

# Remove default products

## SYNOPSIS

Remove starter and unlimited sample products.

## DESCRIPTION

API Management includes two sample products _Starter_ and _Unlimited_.
Accidentally adding APIs to these sample products may expose APIs more than intended.

## RECOMMENDATION

Consider removing starter and unlimited sample products from API Management.

## LINKS

- [Create and publish a product](https://learn.microsoft.com/azure/api-management/api-management-howto-add-products)
