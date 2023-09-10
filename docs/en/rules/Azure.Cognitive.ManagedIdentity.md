---
reviewed: 2022-07-26
severity: Important
pillar: Security
category: Authentication
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
- You can use managed identities to authenticate to any Azure service that supports Azure AD authentication.
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

- Set the `identity.type` to `SystemAssigned` or `UserAssigned`.
- If `identity.type` is `UserAssigned`, reference the identity with `identity.userAssignedIdentities`.

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
- [Azure Policy built-in policy definitions for Azure Cognitive Services](https://docs.microsoft.com/azure/cognitive-services/policy-reference)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.cognitiveservices/accounts)
