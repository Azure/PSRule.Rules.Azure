---
reviewed: 2023-03-05
severity: Awareness
pillar: OE:04 Tools and processes
category: Instrumentation
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.APIDescriptors/
---

# Use API descriptors

## SYNOPSIS

APIs should have a display name and description.

## DESCRIPTION

Each API created in API Management can have a display name and description set.
Using easy to understand descriptions and metadata greatly assist identification for management and usage.

During monitoring from service provider and consumer perspectives:

- Having a clear understanding of the purpose of an API is often important to during analysis.
- Allows for accurate management and clean up of unused APIs.

This information is visible within the developer portal and exported OpenAPI definitions.

## RECOMMENDATION

Consider using display name and description fields on APIs to convey intended purpose and usage.
Display name and description fields should be human readable and easy to understand.

## EXAMPLES

### Configure with Azure template

To deploy API Management APIs that pass this rule:

- Set the `properties.displayName` with a human readable name.
- Set the `properties.description` with an description of the APIs purpose.

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

To deploy API Management APIs that pass this rule:

- Set the `properties.displayName` with a human readable name.
- Set the `properties.description` with an description of the APIs purpose.

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

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Import and publish your first API](https://learn.microsoft.com/azure/api-management/import-and-publish)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service/apis)
