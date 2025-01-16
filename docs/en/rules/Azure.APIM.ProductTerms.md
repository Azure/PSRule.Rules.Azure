---
deprecated: true
severity: Important
pillar: Operational Excellence
category: Configuration
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.ProductTerms/
---

# API Management products do not have legal terms set

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

## NOTES

This rule is deprecated from v1.41.0.
By default, PSRule will not evaluate this rule unless explicitly enabled.
See https://aka.ms/ps-rule-azure/deprecations.

## LINKS

- [Create and publish a product](https://learn.microsoft.com/azure/api-management/api-management-howto-add-products)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/products#ProductContractProperties)
