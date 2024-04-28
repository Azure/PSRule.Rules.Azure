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

### Configure with Azure template

To set capacity for an Application gateway:

- With Autoscaling:
  - Set `autoscaleConfiguration.minCapacity` to any or all of `2`.
- With manual scaling:
  - Set `sku.capacity` to `2` or more.

For example:

```json
{
  "name": "appGw-001",
  "type": "Microsoft.Network/applicationGateways",
  "apiVersion": "2019-09-01",
  "location": "[resourceGroup().location]",
  "zones": [
    "1",
    "2",
    "3"
  ],
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

```

### Configure with Bicep

To set capacity for an Application gateway:

- With Autoscaling:
  - Set `autoscaleConfiguration.minCapacity` to any or all of `2`.
- With manual scaling:
  - Set `sku.capacity` to `2` or more.

For example:

```bicep
resource name_resource 'Microsoft.Network/applicationGateways@2019-09-01' = {
  name: 'appGw-001'
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
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
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/applicationgateways?pivots=deployment-language-bicep)
- [Azure Well-Architected Framework - Reliability](https://learn.microsoft.com/azure/architecture/framework/resiliency/)
