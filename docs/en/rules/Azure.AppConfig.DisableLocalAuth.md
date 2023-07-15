---
reviewed: 2023-07-15
severity: Important
pillar: Security
category: Authentication
resource: App Configuration
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppConfig.DisableLocalAuth/
---

# Use identity-based authentication for App Configuration

## SYNOPSIS

Authenticate App Configuration clients with Azure AD identities.

## DESCRIPTION

Every request to an Azure App Configuration resource must be authenticated.
By default, requests can be authenticated with either Azure Active Directory (Azure AD) credentials,
or by using an access key.
Of these two types of authentication schemes, Azure AD provides superior
security and ease of use over access keys, and is recommended by Microsoft.
To require clients to use Azure AD to authenticate requests, you can disable the usage of access keys for an Azure App Configuration
resource.

When you disable access key authentication for an Azure App Configuration resource, any existing access
keys for that resource are deleted.
Any subsequent requests to the resource using the previously existing access keys will be rejected.
Only requests that are authenticated using Azure AD will succeed.

## RECOMMENDATION

Consider only using Azure AD identities to access App Configuration data.
Then disable authentication based on access keys or SAS tokens.

## EXAMPLES

### Configure with Azure template

To deploy configuration stores that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```json
{
  "type": "Microsoft.AppConfiguration/configurationStores",
  "apiVersion": "2023-03-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "standard"
  },
  "properties": {
    "disableLocalAuth": true,
    "enablePurgeProtection": true,
    "publicNetworkAccess": "Disabled"
  }
}
```

### Configure with Bicep

To deploy configuration stores that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```bicep
resource store 'Microsoft.AppConfiguration/configurationStores@2023-03-01' = {
  name: name
  location: location
  sku: {
    name: 'standard'
  }
  properties: {
    disableLocalAuth: true
    enablePurgeProtection: true
    publicNetworkAccess: 'Disabled'
  }
}
```

### Configure with Bicep Public Registry

To deploy App Configuration Stores that pass this rule:

- Set the `params.disableLocalAuth` parameter to `true`.

For example:

```bicep
module store 'br/public:app/app-configuration:1.1.1' = {
  name: 'store'
  params: {
    skuName: 'Standard'
    disableLocalAuth: true
    enablePurgeProtection: true
    publicNetworkAccess: 'Disabled'
  }
}
```

## LINKS

- [Centralize all identity systems](https://learn.microsoft.com/azure/architecture/framework/security/design-identity-authentication#centralize-all-identity-systems)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-identity-management#im-1-use-centralized-identity-and-authentication-system)
- [Authorize access to Azure App Configuration using Azure Active Directory](https://learn.microsoft.com/azure/azure-app-configuration/concept-enable-rbac)
- [Disable access key authentication](https://learn.microsoft.com/azure/azure-app-configuration/howto-disable-access-key-authentication)
- [Public registry](https://azure.github.io/bicep-registry-modules/#app)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores)
