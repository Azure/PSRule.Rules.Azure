---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.Name/
---

# Use valid API Management service names

## SYNOPSIS

API Management service names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for API Management service names are:

- Between 1 and 50 characters long.
- Alphanumerics and hyphens.
- Start with letter.
- End with letter or number.
- API Management service names must be globally unique.

## RECOMMENDATION

Consider using names that meet API Management naming requirements.
Additionally consider naming resources with a standard naming convention.

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

## NOTES

This rule does not check if API Management service names are unique.

## LINKS

- [Repeatable infrastructure](https://docs.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://docs.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
