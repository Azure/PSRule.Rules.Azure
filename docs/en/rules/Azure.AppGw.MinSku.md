---
severity: Important
pillar: Operational Excellence
category: Deployment
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.MinSku/
---

# Use production Application Gateway SKU

## SYNOPSIS

Application Gateway should use a minimum instance size of Medium.

## DESCRIPTION

An Application Gateway is offered in different versions v1 and v2.
When deploying an Application Gateway v1, three different instance sizes are available: Small, Medium and Large.

Application Gateway v2, Standard_v2 and WAF_v2 SKUs don't offer different instance sizes.

## RECOMMENDATION

Application Gateways using v1 SKUs should be deployed with an instance size of Medium or Large.
Small instance sizes are intended for development and testing scenarios.

## EXAMPLES

### Configure with Azure template

To set the instance size for an Application Gateway V1:

- Set `properties.sku.name` to `Standard_Medium` or `Standard_Large`.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "name": {
      "type": "string",
      "metadata": {
        "description": "The name of the Application Gateway."
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "The location resources will be deployed."
      }
    }
  },
  "resources": [
    {
      "name": "[parameters('name')]",
      "type": "Microsoft.Network/applicationGateways",
      "apiVersion": "2019-09-01",
      "location": "[parameters('location')]",
      "zones": [
        "1",
        "2",
        "3"
      ],
      "tags": {},
      "properties": {
        "sku": {
          "capacity": 2,
          "name": "Standard_Large",
          "tier": "Standard"
        },
        "enableHttp2": false
      }
    }
  ]
}
```

### Configure with Bicep

To set the instance size for an Application Gateway V1:

- Set `properties.sku.name` to `Standard_Medium` or `Standard_Large`.

For example:

```bicep
@description('The name of the Application Gateway.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

resource name_resource 'Microsoft.Network/applicationGateways@2019-09-01' = {
  name: name
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  tags: {}
  properties: {
    sku: {
      capacity: 2
      name: 'Standard_Large'
      tier: 'Standard'
    }
    enableHttp2: false
  }
}
```

## LINKS

- [Azure Application Gateway sizing](https://docs.microsoft.com/azure/application-gateway/overview#sizing)
- [Azure Application Gateway SLA](https://azure.microsoft.com/support/legal/sla/application-gateway/)
- [Azure template reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?pivots=deployment-language-bicep#applicationgatewaysku)
- [Azure Well-Architected Framework - Reliability](https://learn.microsoft.com/en-us/azure/architecture/framework/resiliency/)
