---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.ProductDescriptors/
---

# Use product descriptors

## SYNOPSIS

API Management products should have a display name and description.

## DESCRIPTION

Each product created in API Management can have a display name and description set.
This information is visible within the developer portal.

## RECOMMENDATION

Consider using display name and description fields on products to convey intended purpose and usage.
Display name and description fields should be human readable and easy to understand.

## LINKS

- [Create and publish a product](https://docs.microsoft.com/azure/api-management/api-management-howto-add-products)
- [Azure template reference](https://docs.microsoft.com/azure/templates/microsoft.apimanagement/service/products#ProductContractProperties)
