---
severity: Important
pillar: Security
category: SE:07 Encryption
resource: API Management
resourceType: Microsoft.ApiManagement/service,Microsoft.ApiManagement/service/apis
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.HTTPEndpoint/
---

# API Management allows unencrypted communication with clients

## SYNOPSIS

Unencrypted communication could allow disclosure of information to an untrusted party.

## DESCRIPTION

When an client connects to API Management it can use HTTP or HTTPS.
Each API can be configured to accept connection for HTTP and/ or HTTPS.
When using HTTP, sensitive information may be exposed to an untrusted party.

## RECOMMENDATION

Consider setting the each API to only accept HTTPS connections.
In the portal, this is done by configuring the HTTPS URL scheme.

## EXAMPLES

### Configure with Azure template

To deploy apis that pass this rule:

- Set the `properties.protocols` property to include `https`. AND
- Remove `http` from the `properties.protocols` property.

For example:

```json
{
  "type": "Microsoft.ApiManagement/service/apis",
  "apiVersion": "2022-08-01",
  "name": "[format('{0}/{1}', parameters('name'), 'echo-v1')]",
  "properties": {
    "displayName": "Echo API",
    "description": "An echo API service.",
    "type": "http",
    "path": "echo",
    "serviceUrl": "https://echo.contoso.com",
    "protocols": [
      "https"
    ],
    "apiVersion": "v1",
    "apiVersionSetId": "[resourceId('Microsoft.ApiManagement/service/apiVersionSets', parameters('name'), 'echo')]",
    "subscriptionRequired": true
  },
  "dependsOn": [
    "[resourceId('Microsoft.ApiManagement/service', parameters('name'))]",
    "[resourceId('Microsoft.ApiManagement/service/apiVersionSets', parameters('name'), 'echo')]"
  ]
}
```

### Configure with Bicep

To deploy apis that pass this rule:

- Set the `properties.protocols` property to include `https`. AND
- Remove `http` from the `properties.protocols` property.

For example:

```bicep
resource api 'Microsoft.ApiManagement/service/apis@2022-08-01' = {
  parent: service
  name: 'echo-v1'
  properties: {
    displayName: 'Echo API'
    description: 'An echo API service.'
    type: 'http'
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

<!-- external:avm avm/res/api-management/service apis -->

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#encrypt-data-in-transit)
- [Import and publish a back-end API](https://learn.microsoft.com/azure/api-management/import-api-from-oas#-import-and-publish-a-back-end-api)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/apis)
