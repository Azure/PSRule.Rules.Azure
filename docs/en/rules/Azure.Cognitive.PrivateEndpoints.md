---
reviewed: 2022-07-26
severity: Important
pillar: Security
category: Data flow
resource: Cognitive Services
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Cognitive.PrivateEndpoints/
---

# Use Cognitive Service Private Endpoints

## SYNOPSIS

Use Private Endpoints to access Cognitive Services accounts.

## DESCRIPTION

By default, a public endpoint is enabled for Cognitive Services accounts.
The public endpoint is used for all access except for requests that use a Private Endpoint.
Access through the public endpoint can be disabled or restricted to authorized virtual networks.

Data exfiltration is an attack where an malicious actor does an unauthorized data transfer.
Private Endpoints help prevent data exfiltration by an internal or external malicious actor.
They do this by providing clear separation between public and private endpoints.
As a result, broad access to public endpoints which could be operated by a malicious actor are not required.

## RECOMMENDATION

Consider accessing Cognitive Services accounts by Private Endpoints and disabling public endpoints.

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

## LINKS

- [Traffic flow security in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-flow#data-exfiltration)
- [Configure Azure Cognitive Services virtual networks](https://docs.microsoft.com/azure/cognitive-services/cognitive-services-virtual-networks)
- [Azure Policy built-in policy definitions for Azure Cognitive Services](https://docs.microsoft.com/azure/cognitive-services/policy-reference)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.cognitiveservices/accounts)
