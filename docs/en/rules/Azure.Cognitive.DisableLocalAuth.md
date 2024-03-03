---
reviewed: 2023-10-01
severity: Important
pillar: Security
category: Authentication
resource: Cognitive Services
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cognitive.DisableLocalAuth/
---

# Use identity-based authentication for Cognitive Services accounts

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

Consider only using Azure AD identities to authenticate requests to Cognitive Services accounts.
Once configured, disable authentication based on access keys.

## EXAMPLES

### Configure with Azure template

To deploy accounts that pass this rule:

- Set the `properties.disableLocalAuth` property to `true`.

For example:

```json
{
  "type": "Microsoft.CognitiveServices/accounts",
  "apiVersion": "2023-05-01",
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
resource account 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
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

### Configure with Azure Policy

To address this issue at runtime use the following policies:

- [Azure AI Services resources should have key access disabled (disable local authentication)](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Azure%20Ai%20Services/CognitiveServices_DisableLocalAuth_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/71ef260a-8f18-47b7-abcb-62d0673d94dc`
- [Configure Cognitive Services accounts to disable local authentication methods](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Cognitive%20Services/CognitiveServices_DisableLocalAuth_Modify.json)
  `/providers/Microsoft.Authorization/policyDefinitions/14de9e63-1b31-492e-a5a3-c3f7fd57f555`

## LINKS

- [Use identity-based authentication](https://learn.microsoft.com/azure/well-architected/security/design-identity-authentication#use-identity-based-authentication)
- [Authenticate with Azure Active Directory](https://learn.microsoft.com/azure/ai-services/authentication#authenticate-with-azure-active-directory)
- [Azure Policy built-in policy definitions for Azure AI services](https://learn.microsoft.com/azure/ai-services/policy-reference)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/cognitive-services-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cognitiveservices/accounts)
