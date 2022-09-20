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

- [Create and publish a product](https://docs.microsoft.com/azure/api-management/api-management-howto-add-products)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.apimanagement/service/products#ProductContractProperties)
