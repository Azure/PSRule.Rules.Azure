---
severity: Important
pillar: Security
category: Data protection
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.Ciphers/
---

# Use secure protocols

## SYNOPSIS

API Management should not accept weak or deprecated ciphers.

## DESCRIPTION

API Management provides support for weak or deprecated ciphers.
These older versions are provided for compatibility but are not consider secure.
These Ciphers are enabled by default and need to be set to False.

## RECOMMENDATION

Consider disabling weak or deprecated ciphers.
## EXAMPLES

### Configure with Azure template



For example:

```json

  {
  "apiVersion": "2021-01-01-preview",
  "name": "apim-contoso-test-001",
  "type": "Microsoft.ApiManagement/service",
  "location": "[resourceGroup().location]",
  "tags": {},
  "sku": {
    "name": "Standard",
    "capacity": "1"
  },
  "properties": {
    "publisherEmail": "noreply@contoso.com",
    "publisherName": "Contoso",
    "customProperties": {
        "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TripleDes168": "False", # <----------------- ciphers TripleDes168 disabled  
        "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA": "False", # <----------------- ciphers TLS_RSA_WITH_AES_128_CBC_SHA disabled  
        "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA": "False", # <----------------- ciphers TLS_RSA_WITH_AES_256_CBC_SHA disabled  
        "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_CBC_SHA256": "False", # <----------------- ciphers TLS_RSA_WITH_AES_128_CBC_SHA256 disabled
        "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA": "False", # <----------------- ciphers TLS_ECDHE_RSA_WITH_AES_256_CBC_SHA disabled
        "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_256_CBC_SHA256": "False", # <----------------- ciphers TLS_RSA_WITH_AES_256_CBC_SHA256 disabled
        "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA": "False", # <----------------- ciphers TLS_ECDHE_RSA_WITH_AES_128_CBC_SHA disabled
        "Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Ciphers.TLS_RSA_WITH_AES_128_GCM_SHA256": "False" # <----------------- ciphers TLS_RSA_WITH_AES_128_GCM_SHA256 disabled
      }
  }
}


```

### Configure with Bicep


For example:

```bicep

resource service 'Microsoft.ApiManagement/service@2021-12-01-preview' = {
  name: apim-contoso-test-001
  location: [resourceGroup().location]
  sku: {
    name: 'Standard' // # <-----------------  sku name
    capacity: 1
  }
  zones:{//<-----------------  Zones
    '1'
    '2'
    '3'
  }
  properties: {
    publisherEmail: 'noreply@contoso.com'
    publisherName: 'Contoso',
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
  }
}

```

## LINKS

- [Data encryption in Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Manage protocols and ciphers in Azure API Management](https://docs.microsoft.com/azure/api-management/api-management-howto-manage-protocols-ciphers)
- [Cryptographic Recommendations](https://docs.microsoft.com/security/sdl/cryptographic-recommendations)
