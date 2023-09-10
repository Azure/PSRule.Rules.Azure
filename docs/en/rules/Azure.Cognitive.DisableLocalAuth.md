---
reviewed: 2022-07-26
severity: Important
pillar: Security
category: Authentication
resource: Cognitive Services
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cognitive.DisableLocalAuth/
---

# Use identity-based authentication for Cogitive Services accounts

## SYNOPSIS

Authenticate requests to Cognitive Services with Azure AD identities.

## DESCRIPTION

To send requests to Cognitive Services endpoints, each request must include an authentication header.
Cognitive Services endpoints supports authentication with keys or tokens.
Using an Azure AD token instead of a cryptographic key has some additional security benefits.

With Azure AD authentication, the identity is validated against Azure AD identity provider.
Using Azure AD identities centralizes identity management and auditing.

Once you decide to use Azure AD authentication, you can disable authentication using keys.

## RECOMMENDATION

Consider only using Azure AD identities to authenticate requests to Cogitive Services accounts.
Once configured, disable authentication based on access keys.

## EXAMPLES

### Configure with Azure template

To deploy accounts that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```json
{
    "type": "Microsoft.CognitiveServices/accounts",
    "apiVersion": "2022-03-01",
    "name": "[parameters('name')]",
    "location": "[parameters('location')]",
    "identity": {
        "type": "SystemAssigned"
    },
    "sku": {
        "name": "S0"
    },
    "kind": "CognitiveServices",
    "properties": {
        "publicNetworkAccess": "Disabled",
        "networkAcls": {
            "defaultAction": "Deny"
        },
        "disableLocalAuth": true
    }
}
```

### Configure with Bicep

To deploy accounts that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```bicep
resource account 'Microsoft.CognitiveServices/accounts@2022-03-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'S0'
  }
  kind: 'CognitiveServices'
  properties: {
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
    }
    disableLocalAuth: true
  }
}
```

## LINKS

- [Use identity-based authentication](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication#use-identity-based-authentication)
- [Authenticate with Azure Active Directory](https://docs.microsoft.com/azure/cognitive-services/authentication?tabs=powershell#authenticate-with-azure-active-directory)
- [Azure Policy built-in policy definitions for Azure Cognitive Services](https://docs.microsoft.com/azure/cognitive-services/policy-reference)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.cognitiveservices/accounts)
