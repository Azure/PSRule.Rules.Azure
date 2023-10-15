---
reviewed: 2022-07-26
severity: Important
pillar: Security
category: Application endpoints
resource: Cognitive Services
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cognitive.PublicAccess/
---

# Restrict Cognitive Service endpoints

## SYNOPSIS

Restrict access of Cognitive Services accounts to authorized virtual networks.

## DESCRIPTION

By default, public network access is enabled for a Cognitive Service account.
Service Endpoints and Private Link can be leveraged to restrict access to PaaS endpoints.
When access is restricted, access by malicious actor is from an unauthorized virtual network is mitigated.

Configure service endpoints and private links where appropriate.

## RECOMMENDATION

Consider configuring network access restrictions for Cognitive Services accounts.
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

## LINKS

- [Best practices for endpoint security on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-endpoints#public-endpoints)
- [Configure Azure Cognitive Services virtual networks](https://docs.microsoft.com/azure/cognitive-services/cognitive-services-virtual-networks)
- [Azure Policy built-in policy definitions for Azure Cognitive Services](https://docs.microsoft.com/azure/cognitive-services/policy-reference)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.cognitiveservices/accounts)
