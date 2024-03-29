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
    "apiVersion": "2021-08-01",
    "name": "[format('{0}/{1}', parameters('name'), 'echo-v1')]",
    "properties": {
        "displayName": "Echo API",
        "description": "An echo API service.",
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

To deploy API backends that pass this rule:

- Set the `properties.url` property to a URL that starts with `https://`.

For example:

```json
{
    "type": "Microsoft.ApiManagement/service/backends",
    "apiVersion": "2021-08-01",
    "name": "[format('{0}/{1}', parameters('name'), 'echo')]",
    "properties": {
        "title": "echo",
        "description": "A backend service for the Each API.",
        "protocol": "http",
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

To deploy API backends that pass this rule:

- Set the `properties.url` property to a URL that starts with `https://`.

For example:

```bicep
resource backend 'Microsoft.ApiManagement/service/backends@2021-08-01' = {
  parent: service
  name: 'echo'
  properties: {
    title: 'echo'
    description: 'A backend service for the Each API.'
    protocol: 'http'
    url: 'https://echo.contoso.com'
  }
}
```

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Manage protocols and ciphers in Azure API Management](https://learn.microsoft.com/azure/api-management/api-management-howto-manage-protocols-ciphers)
- [Secure backend services using client certificate authentication in Azure API Management](https://learn.microsoft.com/azure/api-management/api-management-howto-mutual-certificates)
- [Azure deployment reference for APIs](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/apis)
- [Azure deployment reference for backends](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/backends)
