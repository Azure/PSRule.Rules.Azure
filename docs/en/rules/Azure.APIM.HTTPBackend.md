---
severity: Critical
pillar: Security
category: Encryption
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.HTTPBackend/
---

# Use HTTPS backend connections

## SYNOPSIS

Use HTTPS for communication to backend services.

## DESCRIPTION

When API Management connects to the backend API it can use HTTP or HTTPS.
When using HTTP, sensitive information may be exposed to an untrusted party.

Additionally, when configuring backends:

- Use a newer version of TLS such as TLS 1.2.
- Use client certificate authentication from API Management to authenticate to the backend.

## RECOMMENDATION

Consider configuring only backend services configured with HTTPS-based URLs.

## EXAMPLES

### Configure with Azure template

To deploy APIs that pass this rule:

- Set the `properties.serviceUrl` property to a URL that starts with `https://`.

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
    "sku": {
        "name": "Premium",
        "capacity": 1
    },
    "identity": {
        "type": "UserAssigned" 
        "userAssignedIdentities":"[format('{0}', resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', 'identityName'))]": {}
    },
    "protocols": [
      "https"  
    ],
    "apiVersion": "v1",
    "subscriptionRequired": true
  }
}



```

To deploy API backends that pass this rule:

- Set the `properties.url` property to a URL that starts with `https://`.

For example:

```json

{
    "type": "Microsoft.ApiManagement/service/backends",
    "apiVersion": "2021-12-01-preview",
    "name": "[format('{0}/{1}', parameters('name'), 'echo')]",
    "properties": {
        "title": "echo",
        "description": "A backend service for the Each API.",
        "protocol": "https",
        "url": "https://echo.contoso.com"
    },
    "dependsOn": [
        "[resourceId('Microsoft.ApiManagement/service', parameters('name'))]"
    ]
}

```

### Configure with Bicep

To deploy APIs that pass this rule:

- Set the `properties.serviceUrl` property to a URL that starts with `https://`.

For example:

```bicep


```

To deploy API backends that pass this rule:

- Set the `properties.url` property to a URL that starts with `https://`.

For example:

```bicep
resource symbolicname 'Microsoft.ApiManagement/service/backends@2021-12-01-preview' = {
  name: '[format('{0}/{1}', parameters('name'), 'echo')]'
  parent: service
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

- [Data encryption in Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Manage protocols and ciphers in Azure API Management](https://docs.microsoft.com/azure/api-management/api-management-howto-manage-protocols-ciphers)
- [Secure backend services using client certificate authentication in Azure API Management](https://docs.microsoft.com/azure/api-management/api-management-howto-mutual-certificates)
- [Azure deployment reference for APIs](https://docs.microsoft.com/azure/templates/microsoft.apimanagement/service/apis)
- [Azure deployment reference for backends](https://docs.microsoft.com/azure/templates/microsoft.apimanagement/service/backends)
