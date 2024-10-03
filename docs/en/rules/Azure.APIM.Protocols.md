---
reviewed: 2023-03-05
severity: Critical
pillar: Security
category: Encryption
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.Protocols/
---

# Use secure TLS versions for API Management

## SYNOPSIS

API Management should only accept a minimum of TLS 1.2 for client and backend communication.

## DESCRIPTION

API Management provides support for older TLS/ SSL protocols, which are disabled by default.
These older versions are provided for compatibility but are not consider secure.

The following protocols are considered weak or deprecated:

- `SSL 3.0`
- `TLS 1.0`
- `TLS 1.1`

## RECOMMENDATION

Consider configuring the minimum supported TLS version to be 1.2.
Also consider disabling weak or deprecated ciphers.

## EXAMPLES

### Configure with Azure template

To deploy API Management Services that pass this rule:

- Set the following keys to `"False"` _(as a string)_ within the `properties.customProperties` property:
  - `Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10`
  - `Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11`
  - `Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30`
  - `Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10`
  - `Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11`
  - `Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30`

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

To deploy API Management Services that pass this rule:

- Set the following keys to `'False'` _(as a string)_ within the `properties.customProperties` property:
  - `Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls10`
  - `Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Tls11`
  - `Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Protocols.Ssl30`
  - `Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls10`
  - `Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Tls11`
  - `Microsoft.WindowsAzure.ApiManagement.Gateway.Security.Backend.Protocols.Ssl30`

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

<!-- external:avm avm/res/api-management/service customProperties -->

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Manage protocols and ciphers in Azure API Management](https://learn.microsoft.com/azure/api-management/api-management-howto-manage-protocols-ciphers)
- [Cryptographic Recommendations](https://learn.microsoft.com/security/sdl/cryptographic-recommendations)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/service)
