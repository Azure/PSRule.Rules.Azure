---
severity: Important
pillar: Security
category: Identity and access management
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.ProductSubscription/
---

# Require a subscription for products

## SYNOPSIS

Configure products to require a subscription.

## DESCRIPTION

When publishing APIs through Azure API Management (APIM), APIs can be secured using subscription keys.
Client applications that consume published APIs must subscribe before making calls to those APIs.

When combined with policies, subscriptions allow controls such as throttling to be implemented.

## RECOMMENDATION

Consider configuring all API Management products to require a subscription.

## LINKS

- [Subscriptions in Azure API Management](https://docs.microsoft.com/azure/api-management/api-management-subscriptions)
- [Create and publish a product](https://docs.microsoft.com/azure/api-management/api-management-howto-add-products)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.apimanagement/2019-12-01/service/products)
