---
severity: Awareness
category: Security configuration
resource: API Management
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/master/docs/rules/en/Azure.APIM.SampleProducts.md
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

- [Create and publish a product](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-add-products)
