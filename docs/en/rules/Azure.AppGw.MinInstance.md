---
severity: Important
pillar: Reliability
category: Load balancing and failover
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.MinInstance/
---

# Use two or more Application Gateway instances

## SYNOPSIS

Application Gateways should use a minimum of two instances.

## DESCRIPTION

Application Gateways should use two or more instances to be covered by the Service Level Agreement (SLA).
By having two or more instances this allows the App Gateway to meet high availability requirements and reduce downtime.

## RECOMMENDATION

When using Application Gateway v1 or v2 with auto-scaling disabled, specify the number of instances to be two or more.
When auto-scaling is enabled with Application Gateway v2, configure the minimum number of instances to be two or more.

## EXAMPLES

### Configure via Infrastructure as Code template

To set capacity for an Application gateway

Autoscaling:

- Set `autoscaleConfiguration.minCapacity` to any or all of `2`.

Manual Scaling:

- Set `sku.capacitiy` to `2` or more.

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
          "capacity": 2, // Manual Scale
          "name": "WAF_v2",
          "tier": "WAF_v2"
        },
        "autoscaleConfiguration": { //Autoscale
          "minCapacity": 2,
          "maxCapacity": 3
        },
        "webApplicationFirewallConfiguration": {
          "enabled": true,
          "firewallMode": "Detection",
          "ruleSetType": "OWASP",
          "ruleSetVersion": "3.0"
        }
      }
    }
  ]
}
```

### Configure with Bicep

To set capacity for an Application gateway

Autoscaling:

- Set `autoscaleConfiguration.minCapacity` to any or all of `2`.

Manual Scaling:

- Set `sku.capacitiy` to `2` or more.

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
      capacity: 2 // Manual scale
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    autoscaleConfiguration: { // Autoscale
      minCapacity: 1
      maxCapacity: 2
    }
    webApplicationFirewallConfiguration: {
      enabled: true
      firewallMode: 'Detection'
      ruleSetType: 'OWASP'
      ruleSetVersion: '3.0'
    }
  }
}
```

## LINKS

- [Azure Application Gateway SLA](https://azure.microsoft.com/support/legal/sla/application-gateway/)
- [Azure template reference](https://learn.microsoft.com/en-us/azure/templates/microsoft.network/applicationgateways?pivots=deployment-language-bicep)
- [Azure Well-Architected Framework - Reliability](https://learn.microsoft.com/en-us/azure/architecture/framework/resiliency/)
