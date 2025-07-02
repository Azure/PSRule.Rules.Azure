---
reviewed: 2025-07-03
severity: Important
pillar: Reliability
category: RE:04 Target metrics
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

With zero reserved instances, the variable costs are [calculated based on actual usage](https://learn.microsoft.com/azure/application-gateway/understanding-pricing#example-3-b--waf_v2-instance-with-autoscaling-with-0-min-instance-count).

## RECOMMENDATION

Consider using Application Gateway v2 with autoscale enabled which includes two instances by default.
Alternatively, if using manual scaling specify the number of instances to be two or more.

## EXAMPLES

### Configure with Bicep

To configure Applications Gateways that pass this rule:

- With v2 and autoscaling enabled:
  - Set the `autoscaleConfiguration.minCapacity` property to `0` or more.
- With manual scaling:
  - Set the `sku.capacity` property to `2` or more.

For example with v2 and autoscaling enabled:

```bicep
resource appgw 'Microsoft.Network/applicationGateways@2024-07-01' = {
  name: name
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    sslPolicy: {
      policyType: 'Custom'
      minProtocolVersion: 'TLSv1_2'
      cipherSuites: [
        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'
        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'
        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
      ]
    }
    autoscaleConfiguration: {
      minCapacity: 0
      maxCapacity: 4
    }
    firewallPolicy: {
      id: waf.id
    }
  }
}
```

For example manual scaling:

```bicep
resource appgw_manual 'Microsoft.Network/applicationGateways@2024-07-01' = {
  name: name
  location: location
  zones: [
    '1'
    '2'
    '3'
  ]
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
      capacity: 2
    }
    sslPolicy: {
      policyType: 'Custom'
      minProtocolVersion: 'TLSv1_2'
      cipherSuites: [
        'TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384'
        'TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256'
        'TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384'
        'TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256'
      ]
    }
    firewallPolicy: {
      id: waf.id
    }
  }
}
```

<!-- external:avm avm/res/network/application-gateway autoscaleMinCapacity -->

### Configure with Azure template

To configure Applications Gateways that pass this rule:

- With v2 and autoscaling enabled:
  - Set the `autoscaleConfiguration.minCapacity` property to `0` or more.
- With manual scaling:
  - Set the `sku.capacity` property to `2` or more.

For example with v2 and autoscaling enabled:

```json
{
  "type": "Microsoft.Network/applicationGateways",
  "apiVersion": "2024-07-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "zones": [
    "1",
    "2",
    "3"
  ],
  "properties": {
    "sku": {
      "name": "WAF_v2",
      "tier": "WAF_v2"
    },
    "sslPolicy": {
      "policyType": "Custom",
      "minProtocolVersion": "TLSv1_2",
      "cipherSuites": [
        "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
        "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
        "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
        "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
      ]
    },
    "autoscaleConfiguration": {
      "minCapacity": 0,
      "maxCapacity": 4
    },
    "firewallPolicy": {
      "id": "[resourceId('Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies', 'agwwaf')]"
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies', 'agwwaf')]"
  ]
}
```

For example manual scaling:

```json
{
  "type": "Microsoft.Network/applicationGateways",
  "apiVersion": "2024-07-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "zones": [
    "1",
    "2",
    "3"
  ],
  "properties": {
    "sku": {
      "name": "WAF_v2",
      "tier": "WAF_v2",
      "capacity": 2
    },
    "sslPolicy": {
      "policyType": "Custom",
      "minProtocolVersion": "TLSv1_2",
      "cipherSuites": [
        "TLS_ECDHE_ECDSA_WITH_AES_256_GCM_SHA384",
        "TLS_ECDHE_ECDSA_WITH_AES_128_GCM_SHA256",
        "TLS_ECDHE_RSA_WITH_AES_256_GCM_SHA384",
        "TLS_ECDHE_RSA_WITH_AES_128_GCM_SHA256"
      ]
    },
    "firewallPolicy": {
      "id": "[resourceId('Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies', 'agwwaf')]"
    }
  },
  "dependsOn": [
    "[resourceId('Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies', 'agwwaf')]"
  ]
}
```

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Azure Application Gateway SLA](https://www.microsoft.com/licensing/docs/view/Service-Level-Agreements-SLA-for-Online-Services)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/applicationgateways)
