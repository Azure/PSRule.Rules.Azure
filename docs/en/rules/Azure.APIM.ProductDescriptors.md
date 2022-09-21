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

## EXAMPLES

### Configure with Azure template

To set the display name and the description

set properties.displayName	for the resource type "apis". Dispaly name must be 1 to 300 characters long.

set	properties.description resource type "apis". May include HTML formatting tags.

For example:

```json

{
  "type": "Microsoft.ApiManagement/service/products",
  "apiVersion": "2021-12-01-preview",
  "name": "apim-contoso-test-001/custom-product",
  "properties": {
    "approvalRequired": true, 
    "description": "Custom Product, subscription and approval is required to get the subscription key to call the APIs in Contoso", # <----------------- description
    "displayName": "Custom Product", # <----------------- display name
    "state": "published",
    "subscriptionRequired": true,
    "subscriptionsLimit": 1
  }
}

```

### Configure with Bicep

To set the display name and the description

set properties.displayName	for the resource "Microsoft.ApiManagement/service/apis@2021-08-01". Dispaly name must be 1 to 300 characters long.

set	properties.description for the resource "Microsoft.ApiManagement/service/apis@2021-08-01". May include HTML formatting tags.

For example:

```bicep

resource product 'Microsoft.ApiManagement/service/products@2021-12-01-preview' = {
  name: 'apim-contoso-test-001/custom-product'
  properties: {
    approvalRequired: true 
    description: 'Custom Product, subscription and approval is required to get the subscription key to call the APIs in Contoso'  // <----------------- description
    displayName: 'Custom Product' // <----------------- display name
    state: 'published'
    subscriptionRequired: true
    subscriptionsLimit: 1
  }
}

```

## LINKS

- [Create and publish a product](https://docs.microsoft.com/azure/api-management/api-management-howto-add-products)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.apimanagement/service/products#ProductContractProperties)
