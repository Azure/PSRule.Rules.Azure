---
reviewed: 2023-12-11
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: App Configuration
resourceType: Microsoft.AppConfiguration/configurationStores
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppConfig.DisableLocalAuth/
---

# App Configuration access keys are enabled

## SYNOPSIS

Access keys allow depersonalized access to App Configuration using a shared secret.

## DESCRIPTION

Every request to an Azure App Configuration resource must be authenticated.
App Configuration supports authenticating requests using either Entra ID (previously Azure AD) identities or access keys.
Using Entra ID identities:

- Centralizes identity management and auditing.
- Allows granting of permissions using role-based access control (RBAC).
- Provides support for advanced security features such as conditional access and multi-factor authentication (MFA) when applicable.

To require clients to use Entra ID to authenticate requests, you can disable the usage of access keys for an Azure App Configuration
resource.

When you disable access key authentication for an Azure App Configuration resource, any existing access
keys for that resource are deleted.
Any subsequent requests to the resource using the previously existing access keys will be rejected.
Only requests that are authenticated using Entra ID will succeed.

## RECOMMENDATION

Consider only using Entra ID identities to access App Configuration data.
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

<!-- external:avm avm/res/app-configuration/configuration-store disableLocalAuth -->

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [App Configuration stores should have local authentication methods disabled](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/App%20Configuration/DisableLocalAuth_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/b08ab3ca-1062-4db3-8803-eec9cae605d6`
- [Configure App Configuration stores to disable local authentication methods](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/App%20Configuration/DisableLocalAuth_Modify.json)
  `/providers/Microsoft.Authorization/policyDefinitions/72bc14af-4ab8-43af-b4e4-38e7983f9a1f`

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/security-controls-v3-identity-management#im-1-use-centralized-identity-and-authentication-system)
- [Authorize access to Azure App Configuration using Microsoft Entra ID](https://learn.microsoft.com/azure/azure-app-configuration/concept-enable-rbac)
- [Disable access key authentication](https://learn.microsoft.com/azure/azure-app-configuration/howto-disable-access-key-authentication)
- [Azure security baseline for Azure App Configuration](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-app-configuration-security-baseline)
- [Azure Policy built-in definitions for Azure App Configuration](https://learn.microsoft.com/azure/azure-app-configuration/policy-reference)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.appconfiguration/configurationstores)
