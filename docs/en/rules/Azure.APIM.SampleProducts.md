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

## EXAMPLES

### Configure with Azure template

Add the custom products, and assign them to the API services added to the API management Service.

For example:

```json
    {
        "type": "Microsoft.ApiManagement/service/products",
        "apiVersion": "2021-08-01",
        "name": "apiService-001/custom-product",
        "properties": {
          "displayName": "custom-product",
          "description": "custom-product for the API services for Contoso.",
          "approvalRequired": true,
          "subscriptionRequired": true,
          "state":"Published"

        },
        "dependsOn": [
          "[resourceId('Microsoft.ApiManagement/service', 'apiService-001')]"
        ]
      },
      {
        "type": "Microsoft.ApiManagement/service/products/apis",
        "apiVersion": "2021-12-01-preview",
        "name": "apiService-001/custom-product/exampleApi",
        "dependsOn": [
            "[resourceId('Microsoft.ApiManagement/service/products', 'apiService-001', 'custom-product')]",
            "[resourceId('Microsoft.ApiManagement/service', 'apiService-001')]"
        ]
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
  name: 'apiService-001'
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
  }
}

resource product 'Microsoft.ApiManagement/service/products@2021-08-01' = {
  name: 'custom-product'
  parent: apim
  properties: {
    approvalRequired: true
    description: 'custom-product for the API services for Contoso.'
    displayName: 'custom-product'
    state: 'published'
    subscriptionRequired: true
    subscriptionsLimit: 1
  }
}

resource productApi 'Microsoft.ApiManagement/service/products/apis@2021-08-01' = {
  name: 'apiService-001/custom-product/exampleApi'
  parent: product
}

```


## LINKS

- [Create and publish a product](https://docs.microsoft.com/azure/api-management/api-management-howto-add-products)
