---
severity: Important
pillar: Operational Excellence
category: Configuration
resource: API Management
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.APIM.ProductTerms.md
---

# Use API product legal terms

## SYNOPSIS

Set legal terms for each product registered in API Management.

## DESCRIPTION

Within API Management a product is created to publish one or more APIs.
For each product legal terms can be specified.
When set, developers using the developer portal are required to accept the terms to subscribe to a product.
Use these terms to set expectations on acceptable use of the included APIs.

Acceptance of legal terms is bypassed when an administrator creates a subscription.

## RECOMMENDATION

Consider configuring legal terms for all products to declare acceptable use of included APIs.

## LINKS

- [Create and publish a product](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-add-products)
- [Azure template reference](https://docs.microsoft.com/en-us/azure/templates/microsoft.apimanagement/service/products#ProductContractProperties)
