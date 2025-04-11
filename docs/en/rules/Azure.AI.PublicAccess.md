---
reviewed: 2024-03-26
severity: Important
pillar: Security
category: SE:06 Network controls
resource: AI Service
resourceType: Microsoft.CognitiveServices/accounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AI.PublicAccess/
---

# Restrict Azure AI service endpoints

## SYNOPSIS

Restrict access of Azure AI services to authorized virtual networks.

## DESCRIPTION

By default, public network access is enabled for a Azure AI service accounts (previously known as Cognitive Services).
Service Endpoints and Private Link can be leveraged to restrict access to PaaS endpoints.
When access is restricted, access by malicious actor is from an unauthorized virtual network is mitigated.

Configure service endpoints and private links where appropriate.

## RECOMMENDATION

Consider configuring network access restrictions for Azure AI service accounts.
Limit access to accounts so that access is permitted from authorized virtual networks only.

## EXAMPLES

### Configure with Azure template

To deploy accounts that pass this rule:

- Set the `properties.networkAcls.defaultAction` property to `Deny`, or
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

- Set the `properties.networkAcls.defaultAction` property to `Deny`, or
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

<!-- external:avm avm/res/cognitive-services/account networkAcls,publicNetworkAccess -->

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Configure Azure AI services virtual networks](https://learn.microsoft.com/azure/ai-services/cognitive-services-virtual-networks)
- [Azure Policy built-in policy definitions for Azure AI services](https://learn.microsoft.com/azure/ai-services/policy-reference)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cognitiveservices/accounts)
