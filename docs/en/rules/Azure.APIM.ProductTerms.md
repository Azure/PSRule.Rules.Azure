---
severity: Important
pillar: Operational Excellence
category: Configuration
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.ProductTerms/
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
    "description": "Custom Product, subscription and approval is required to get the subscription key to call the APIs in Contoso", 
    "displayName": "Custom Product", 
    "state": "published",
    "subscriptionRequired": true, 
    "subscriptionsLimit": 1,
    "terms" : "Accept this legal terms for the usage of the custom product, to call the APIs" # <----------------- Terms
  }
}

```

### Configure with Bicep

To set the display name and the description

set properties.displayName	for the resource "Microsoft.ApiManagement/service/apis@2021-08-01". Dispaly name must be 1 to 300 characters long.

set	properties.description for the resource "Microsoft.ApiManagement/service/apis@2021-08-01". May include HTML formatting tags.

For example:

```bicep

resource api 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: service
  name: 'echo-v1'
  properties: {
    displayName: 'Echo API'
    description: 'An echo API service.'
    path: 'echo'
    serviceUrl: 'https://echo.contoso.com'
    protocols: [
      'https'
    ]
    apiVersion: 'v1'
    apiVersionSetId: version.id
    subscriptionRequired: true
    terms: 'Accept this legal terms for the usage of the custom product, to call the APIs' // <----------------- Terms
  }
}

```


## LINKS

- [Create and publish a product](https://docs.microsoft.com/azure/api-management/api-management-howto-add-products)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.apimanagement/service/products#ProductContractProperties)
