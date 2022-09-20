---
severity: Important
pillar: Security
category: Identity and access management
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.ManagedIdentity/
---

# API Management uses a managed identity

## SYNOPSIS

Configure managed identities to access Azure resources.

## DESCRIPTION

API Management must authenticate to access Azure resources such as Key Vault.
Use Key Vault to store certificates and secrets used within API Management.

## RECOMMENDATION

Consider configuring a managed identity for each API Management instance.
Also consider using managed identities to authenticate to related Azure services.

## EXAMPLES

### Configure with Azure template

To deploy App Services that pass this rule:

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

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
        "type": "SystemAssigned" # <----------------- Identity type set to System Assigned
    },
    "protocols": [
      "https"  
    ],
    "apiVersion": "v1",
    "subscriptionRequired": true
  }
}


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
        "type": "UserAssigned" # <----------------- Identity type set to User Assigned
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

### Configure with Bicep

To deploy App Services that pass this rule:

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

For example:

```bicep

resource api 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: service
  name: 'apim-contoso-test-001'
  properties: {
    displayName: 'Example Echo v1 API' // <----------------- Display name
    description: 'An echo API service.' // <----------------- Descriptiuon
    path: 'echo'
    serviceUrl: 'https://echo.contoso.com'
    sku: [
      name: 'Premium'
      capacity:1
    ]
    identity:[
      type: 'SystemAssigned'
    ]
    protocols: [
      'https'
    ]
    apiVersion: 'v1'
    subscriptionRequired: true
  }
}

resource api 'Microsoft.ApiManagement/service/apis@2021-08-01' = {
  parent: service
  name: 'apim-contoso-test-001'
  properties: {
    displayName: 'Example Echo v1 API' // <----------------- Display name
    description: 'An echo API service.' // <----------------- Descriptiuon
    path: 'echo'
    serviceUrl: 'https://echo.contoso.com'
    sku: [
      name: 'Premium'
      capacity:1
    ]
    identity:[
      type: 'UserAssigned'
      userAssignedIdentities:'/subscriptions/{subscriptionId}/resourceGroups/{resourceGroupName}/
providers/Microsoft.ManagedIdentity/userAssignedIdentities/{identityName}'
    ]
    protocols: [
      'https'
    ]
    apiVersion: 'v1'
    subscriptionRequired: true
  }
}





```

## LINKS

- [Use identity-based authentication](https://docs.microsoft.com/azure/architecture/framework/security/design-identity-authentication#use-identity-based-authentication)
- [Use managed identities in Azure API Management](https://docs.microsoft.com/azure/api-management/api-management-howto-use-managed-service-identity)
- [Authenticate with managed identity](https://docs.microsoft.com/azure/api-management/api-management-authentication-policies#ManagedIdentity)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.apimanagement/service)
