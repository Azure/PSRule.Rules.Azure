---
reviewed: 2024-03-26
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Azure AI
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AI.DisableLocalAuth/
---

# Use identity-based authentication for Azure AI accounts

## SYNOPSIS

Authenticate requests to Azure AI services with Entra ID identities.

## DESCRIPTION

To send requests to Azure AI service endpoints (previously known as Cognitive Services),
each request must include an authentication header.
Azure AI service endpoints supports authentication with keys or access tokens.
Using an Entra ID access token instead of a cryptographic key has some additional security benefits.

With Entra ID authentication, an authorized identity is issued an OAuth2 access token issued by Entra ID.
Using Entra ID as the identity provider centralizes identity management and auditing.

Once you decide to use Entra ID authentication, you can disable authentication using keys.

## RECOMMENDATION

Consider only using Entra ID identities to authenticate requests to Azure AI service accounts.
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

- [Azure AI Services resources should have key access disabled (disable local authentication)](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Azure%20Ai%20Services/DisableLocalAuth_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/71ef260a-8f18-47b7-abcb-62d0673d94dc`
- [Configure Cognitive Services accounts to disable local authentication methods](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Cognitive%20Services/DisableLocalAuth_Modify.json)
  `/providers/Microsoft.Authorization/policyDefinitions/14de9e63-1b31-492e-a5a3-c3f7fd57f555`

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/cognitive-services-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [Authenticate with Microsoft Entra ID](https://learn.microsoft.com/azure/ai-services/authentication#authenticate-with-microsoft-entra-id)
- [Azure Policy built-in policy definitions for Azure AI services](https://learn.microsoft.com/azure/ai-services/policy-reference)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cognitiveservices/accounts)
