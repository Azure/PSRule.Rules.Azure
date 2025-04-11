---
reviewed: 2024-03-26
severity: Important
pillar: Security
category: SE:06 Network controls
resource: AI Service
resourceType: Microsoft.CognitiveServices/accounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AI.PrivateEndpoints/
---

# Use Azure AI services Private Endpoints

## SYNOPSIS

Use Private Endpoints to access Azure AI services accounts.

## DESCRIPTION

By default, a public endpoint is enabled for Azure AI services accounts (previously known as Cognitive Services).
The public endpoint is used for all access except for requests that use a Private Endpoint.
Access through the public endpoint can be disabled or restricted to authorized virtual networks.

Data exfiltration is an attack where an malicious actor does an unauthorized data transfer.
Private Endpoints help prevent data exfiltration by an internal or external malicious actor.
They do this by providing clear separation between public and private endpoints.
As a result, broad access to public endpoints which could be operated by a malicious actor is not required.

## RECOMMENDATION

Consider accessing Azure AI services accounts by Private Endpoints and disabling public endpoints.

## EXAMPLES

### Configure with Azure template

To deploy accounts that pass this rule:

- Set the `properties.publicNetworkAccess` property to `Disabled`.

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

- Set the `properties.publicNetworkAccess` property to `Disabled`.

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

<!-- external:avm avm/res/cognitive-services/account publicNetworkAccess -->

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Configure Azure AI services virtual networks](https://learn.microsoft.com/azure/ai-services/cognitive-services-virtual-networks)
- [Azure Policy built-in policy definitions for Azure AI services](https://learn.microsoft.com/azure/ai-services/policy-reference)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cognitiveservices/accounts)
