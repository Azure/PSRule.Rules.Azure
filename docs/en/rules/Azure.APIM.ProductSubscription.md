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

## EXAMPLES

### Configure with Azure template

To set the display name and the description

set properties.displayName	for the resource type "apis". Dispaly name must be 1 to 300 characters long.

set	properties.description resource type "apis". May include HTML formatting tags.

For example:

```json
{
  "apiVersion": "2021-08-01",
  "name": "apiService-001",
  "type": "Microsoft.ApiManagement/service",
  "location": "[resourceGroup().location]",
  "tags": {},
  "sku": {
    "name": "Standard",
    "capacity": "1"
  },
  "properties": {
    "publisherEmail": "noreply@contoso.com",
    "publisherName": "Contoso"
  },
  "resources": [
    {
      "apiVersion": "2017-03-01",
      "type": "apis",
      "name": "exampleApi",
      "dependsOn": [
        "[concat('Microsoft.ApiManagement/service/apiService-001')]"
      ],
      "properties": {
        "displayName": "Example API Name",
        "description": "Description for example API",
        "serviceUrl": "https://example.net",
        "path": "exampleapipath",
        "protocols": [  
          "HTTPS"
        ]
      },
      "resources": [
        {
          "apiVersion": "2017-03-01",
          "type": "operations",
          "name": "exampleOperationsGET",
          "dependsOn": [
            "[concat('Microsoft.ApiManagement/service/apiService-001/apis/exampleApi')]"
          ],
          "properties": {
            "displayName": "GET resource",
            "method": "GET",
            "urlTemplate": "/resource",
            "description": "A demonstration of a GET call"
          },
        }
      ]
    }
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
  }
}
```


## LINKS

- [Subscriptions in Azure API Management](https://docs.microsoft.com/azure/api-management/api-management-subscriptions)
- [Create and publish a product](https://docs.microsoft.com/azure/api-management/api-management-howto-add-products)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.apimanagement/2019-12-01/service/products)
