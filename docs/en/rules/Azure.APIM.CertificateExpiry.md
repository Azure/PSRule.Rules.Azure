---
severity: Important
pillar: Operational Excellence
category: Deployment
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.CertificateExpiry/
---

# API Management uses current certificates

## SYNOPSIS

Renew certificates used for custom domain bindings.

## DESCRIPTION

When custom domains are configured within an API Management service.
A certificate must be assigned to allow traffic to be transmitted using TLS.

Each certificate has an expiry date, after which the certificate is not valid.
After expiry, client connections to the API Management service will reject the certificate.

## RECOMMENDATION

Consider renewing certificates before expiry to prevent service issues.
## EXAMPLES

### Configure with Azure template

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

By default, this rule fails when certificates have less than 30 days remaining before expiry.

To configure this rule:

- Override the `Azure_MinimumCertificateLifetime` configuration value with the minimum number of days until expiry.

## LINKS

- [Configure a custom domain name](https://docs.microsoft.com/azure/api-management/configure-custom-domain#use-the-azure-portal-to-set-a-custom-domain-name)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.apimanagement/2019-12-01/service#hostnameconfiguration-object)
