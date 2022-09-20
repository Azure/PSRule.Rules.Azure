---
severity: Important
pillar: Security
category: Data protection
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.HTTPEndpoint/
---

# Publish APIs through HTTPS connections

## SYNOPSIS

Enforce HTTPS for communication to API clients.

## DESCRIPTION

When an client connects to API Management it can use HTTP or HTTPS.
Each API can be configured to accept connection for HTTP and/ or HTTPS.
When using HTTP, sensitive information may be exposed to an untrusted party.

## RECOMMENDATION

Consider setting the each API to only accept HTTPS connections.
In the portal, this is done by configuring the HTTPS URL scheme.

## EXAMPLES

### Configure with Azure template

To set the display name and the description

set properties.displayName	for the resource type "apis". Dispaly name must be 1 to 300 characters long.

set	properties.description resource type "apis". May include HTML formatting tags.

For example:

```json
{
  "type": "Microsoft.ApiManagement/service/apis",
  "apiVersion": "2021-01-01-preview",
  "name": "apim-contoso-test-001",
  "properties": {
    "displayName": "Example Echo v1 API", 
    "description": "An echo API service.", 
    "path": "echo",
    "serviceUrl": "https://echo.contoso.com",
    "protocols": [
      "https" # <----------------- making sure the http end point is https 
    ],
    "apiVersion": "v1",
    "subscriptionRequired": true
  }
}
```

### Configure with Bicep

To set the display name and the description

set properties.displayName	for the resource "Microsoft.ApiManagement/service/apis@2021-08-01". Dispaly name must be 1 to 300 characters long.

set	properties.description for the resource "Microsoft.ApiManagement/service/apis@2021-08-01". May include HTML formatting tags.

For example:

```bicep

resource api 'Microsoft.ApiManagement/service/apis@2021-12-01-preview' = {
  parent: service
  name: 'apim-contoso-test-001'
  properties: {
    displayName: 'Example Echo v1 API'
    description: 'An echo API service.'
    path: 'echo'
    serviceUrl: 'https://echo.contoso.com'
    protocols: [
      'https'
    ]
    apiVersion: 'v1'
    subscriptionRequired: true
  }
}
```

## LINKS

- [Data encryption in Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Import and publish a back-end API](https://docs.microsoft.com/azure/api-management/import-api-from-oas#-import-and-publish-a-back-end-api)
