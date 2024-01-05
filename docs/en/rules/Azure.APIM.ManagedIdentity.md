---
reviewed: 2023-03-05
severity: Important
pillar: Security
category: SE:05 Identity and access management
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

To deploy API Management services that pass this rule:

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

For example:

```json
{
    "type": "Microsoft.ApiManagement/service",
    "apiVersion": "2021-08-01",
    "name": "[parameters('name')]",
    "location": "[parameters('location')]",
    "sku": {
        "name": "Premium",
        "capacity": 1
    },
    "identity": {
        "type": "SystemAssigned"
    },
    "properties": {
        "publisherEmail": "[parameters('publisherEmail')]",
        "publisherName": "[parameters('publisherName')]",
        "customProperties": {
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10": "False",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11": "False",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30": "False",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10": "False",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11": "False",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30": "False",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2": "True",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168": "False",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA": "False",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA": "False",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA256": "False",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA": "False",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA256": "False",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA": "False",
            "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_GCM_SHA256": "False"
        },
        "apiVersionConstraint": {
            "minApiVersion": "2021-08-01"
        }
    }
}
```

### Configure with Bicep

To deploy API Management services that pass this rule:

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

For example:

```bicep
resource service 'Microsoft.ApiManagement/service@2021-08-01' = {
  name: name
  location: location
  sku: {
    name: 'Premium'
    capacity: 1
  }
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    publisherEmail: publisherEmail
    publisherName: publisherName
    customProperties: {
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Protocols.Server.Http2': 'True'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA256': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA256': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA': 'False'
      'Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_GCM_SHA256': 'False'
    }
    apiVersionConstraint: {
      minApiVersion: '2021-08-01'
    }
  }
}
```

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access#resource-identity)
- [What are managed identities for Azure resources?](https://learn.microsoft.com/entra/identity/managed-identities-azure-resources/overview)
- [Use managed identities in Azure API Management](https://learn.microsoft.com/azure/api-management/api-management-howto-use-managed-service-identity)
- [Authenticate with managed identity](https://learn.microsoft.com/azure/api-management/api-management-policies#authentication-policies)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service)
