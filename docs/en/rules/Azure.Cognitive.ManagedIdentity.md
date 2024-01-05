---
reviewed: 2024-01-03
severity: Important
pillar: Security
category: SE:05 Identity and access management
resource: Cognitive Services
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cognitive.ManagedIdentity/
---

# Use Managed Identity for Cognitive Services accounts

## SYNOPSIS

Configure managed identities to access Azure resources.

## DESCRIPTION

Cognitive Services must authenticate to Azure resources such storage accounts.
To authenticate to Azure resources, Cognitive Services can use managed identities.

Using Azure managed identities have the following benefits:

- You don't need to store or manage credentials.
  Azure automatically generates tokens and performs rotation.
- You can use managed identities to authenticate to any Azure service that supports Entra ID (previously Azure AD) authentication.
- Managed identities can be used without any additional cost.

## RECOMMENDATION

Consider configuring a managed identity for each Cognitive Services account.

## EXAMPLES

### Configure with Azure template

To deploy accounts that pass this rule:

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

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
  "kind": "TextAnalytics",
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

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

For example:

```bicep
resource language 'Microsoft.CognitiveServices/accounts@2023-05-01' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  sku: {
    name: 'S0'
  }
  kind: 'TextAnalytics'
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

- [Cognitive Services accounts should use a managed identity](https://github.com/Azure/azure-policy/blob/master/built-in-policies/policyDefinitions/Cognitive%20Services/CognitiveServices_ManagedIdentity_Audit.json)
  `/providers/Microsoft.Authorization/policyDefinitions/fe3fd216-4f83-4fc1-8984-2bbec80a3418`.

## NOTES

Configuration of additional Azure resources is not required for all Cognitive Services.
This rule will run for the following Cognitive Services:

- `TextAnalytics` - Language service.

## LINKS

- [SE:05 Identity and access management](https://learn.microsoft.com/azure/well-architected/security/identity-access#resource-identity)
- [Azure Policy built-in policy definitions for Azure AI services](https://learn.microsoft.com/azure/ai-services/policy-reference)
- [IM-1: Use centralized identity and authentication system](https://learn.microsoft.com/security/benchmark/azure/baselines/cognitive-services-security-baseline#im-1-use-centralized-identity-and-authentication-system)
- [IM-3: Manage application identities securely and automatically](https://learn.microsoft.com/security/benchmark/azure/baselines/cognitive-services-security-baseline#im-3-manage-application-identities-securely-and-automatically)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cognitiveservices/accounts)
