---
severity: Awareness
pillar: Operational Excellence
category: Tagging and resource naming
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.APIDescriptors/
---

# Use API descriptors

## SYNOPSIS

API Management APIs should have a display name and description.

## DESCRIPTION

Each API created in API Management can have a display name and description set.
This information is visible within the developer portal and exported OpenAPI definitions.

## RECOMMENDATION

Consider using display name and description fields on APIs to convey intended purpose and usage.
Display name and description fields should be human readable and easy to understand.

## EXAMPLES

### Configure with Azure template

To set the display name and the description

For APIs :
set properties.displayName	for the resource type "apis". Dispaly name must be 1 to 300 characters long.
set	properties.description resource type "apis". May include HTML formatting tags.

For Operations:
set properties.displayName	for the resource type "operations". Dispaly name must be 1 to 300 characters long.
set	properties.description resource type "operations". May include HTML formatting tags.

For example:

**API deployment template**

```json

{
  "type": "Microsoft.ApiManagement/service/apis",
  "apiVersion": "2021-01-01-preview",
  "name": "apim-contoso-test-001",
  "properties": {
    "displayName": "Example Echo v1 API", # <----------------- Display name
    "description": "An echo API service.", # <----------------- Descriotion 
    "path": "echo",
    "serviceUrl": "https://echo.contoso.com",
    "protocols": [
      "https"
    ],
    "apiVersion": "v1",
    "subscriptionRequired": true
  }
}

```
**Operation deployment template**

```json

{
  "apiVersion": "2021-01-01-preview",
  "type": "Microsoft.ApiManagement/service/apis/operations",
  "name": "exampleOperationsGET",
  "dependsOn": [
    "[concat('Microsoft.ApiManagement/service/apim-contoso-test-001/apis/echo')]"
  ],
  "properties": {
    "displayName": "GET resource", # <----------------- Display name
    "method": "GET", 
    "urlTemplate": "/resource",
    "description": "A demonstration of a GET call" # <----------------- Description
  },
}



```
### Configure with Bicep


For example:

**API deployment template**

```bicep

resource api 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: service
  name: 'apim-contoso-test-001'
  properties: {
    displayName: 'Example Echo v1 API' // <----------------- Display name
    description: 'An echo API service.' // <----------------- Descriptiuon
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

**Operation deployment template**

```bicep

resource operation 'Microsoft.ApiManagement/service/apis/operations@2021-12-01-preview' = {
  name: 'exampleOperationsGET'
  parent: api
  properties: {
    description: 'A demonstration of a GET call' // <----------------- Descriptiuon
    displayName: 'GET resource' // <----------------- Display name
    method: 'GET'
    urlTemplate: '/resource'
  }
}

```



## LINKS

- [Import and publish your first API](https://docs.microsoft.com/azure/api-management/import-and-publish)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.apimanagement/service/apis#ApiCreateOrUpdateProperties)
