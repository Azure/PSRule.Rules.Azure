---
severity: Important
pillar: Reliability
category: Load balancing and failover
resource: Application Gateway
resourceType: Microsoft.Network/applicationGateways
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.MinInstance/
---

# Use two or more Application Gateway instances

## SYNOPSIS

Application Gateways should use a minimum of two instances.

## DESCRIPTION

Application Gateway should use two or more instances to be covered by the Service Level Agreement (SLA).

By having two or more instances this allows the App Gateway to meet high availability requirements and reduce downtime.

When autoscaling is enabled, Application Gateway v2 SKUs:

- Always include two instances internally within the service, even when minimum capacity is set to `0`.
- Use these internal instances to provide high availability, handle initial traffic load, and scale out the Application Gateway.
- Can be set a higher minimum capacity greater than `2` if you expect sudden traffic spikes or unpredictable traffic patterns.

When manually deploying Application Gateway v2 via the Azure Portal, by default autoscale is enabled.

If manually scaling Application Gateway, specify at least two instances for high availability and to support network
traffic based on expected load.

With zero reserved instances, the variable costs are [calculated based on actual usage](https://learn.microsoft.com/en-us/azure/application-gateway/understanding-pricing#example-3-b--waf_v2-instance-with-autoscaling-with-0-min-instance-count).

## RECOMMENDATION

Consider using Application Gateway v2 with autoscale enabled which includes two instances by default.
Alternatively, if using manual scaling specify the number of instances to be two or more.


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
