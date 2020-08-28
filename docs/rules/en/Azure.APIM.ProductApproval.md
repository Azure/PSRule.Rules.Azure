---
severity: Important
pillar: Security
category: Identity and access management
resource: API Management
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.APIM.ProductApproval.md
---

# Require approval for products

## SYNOPSIS

Configure products to require approval.

## DESCRIPTION

When publishing APIs through Azure API Management (APIM), APIs are assigned to products.
Access to use an API is delegated through a product.

When products do not require approval, users can create a subscription for a product without approval.

## RECOMMENDATION

Consider configuring all API Management products to require approval.

## LINKS

- [Create and publish a product](https://docs.microsoft.com/en-us/azure/api-management/api-management-howto-add-products)
- [Azure template reference](https://docs.microsoft.com/en-us/azure/templates/microsoft.apimanagement/2019-12-01/service/products)
