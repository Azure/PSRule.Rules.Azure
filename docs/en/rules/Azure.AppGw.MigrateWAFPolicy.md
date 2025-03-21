---
severity: Critical
pillar: Reliability
category: RE:04 Target metrics
resource: Application Gateway
resourceType: Microsoft.Network/applicationGateways
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.MigrateWAFPolicy/
---

# Migrate to Application Gateway WAF policy

## SYNOPSIS

Migrate to Application Gateway WAF policy.

## DESCRIPTION

Application Gateway V2 supports two configuration modes for WAF:

- Define and reference an WAF policy that can be reused across multiple Application Gateways.
- Specify the WAF configuration tied directly a specific Application Gateway.
  This is done by setting the `properties.webApplicationFirewallConfiguration` property.

Setting the Application Gateway WAF configuration is depreciated and will be retired on 15 March 2027.

## RECOMMENDATION

Consider upgrading Application Gateway to use WAF v2 referencing a WAF policy.

## EXAMPLES

### Configure with Azure template

To deploy Application Gateways that pass this rule:

- Deploy an Application Gateway with the `WAF_v2` SKU.
- Migrate any WAF configuration from `properties.webApplicationFirewallConfiguration` to a separate WAF policy.
- Set the `properties.firewallPolicy.id` property to reference the WAF policy resource by ID.

For example:

```json
{
  "type": "Microsoft.Network/applicationGateways",
  "apiVersion": "2024-01-01",
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
      "minCapacity": 2,
      "maxCapacity": 3
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

### Configure with Bicep

To deploy Application Gateways that pass this rule:

- Deploy an Application Gateway with the `WAF_v2` SKU.
- Migrate any WAF configuration from `properties.webApplicationFirewallConfiguration` to a separate WAF policy.
- Set the `properties.firewallPolicy.id` property to reference the WAF policy resource by ID.

For example:

```bicep
resource appgw 'Microsoft.Network/applicationGateways@2024-01-01' = {
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
      minCapacity: 2
      maxCapacity: 3
    }
    firewallPolicy: {
      id: waf.id
    }
  }
}
```

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Retirement: Support for Application Gateway Web Application Firewall v2 Configuration is ending](https://azure.microsoft.com/updates/retirement-support-for-application-gateway-web-application-firewall-v2-configuration-is-ending/)
- [Upgrade WAF v2 with legacy WAF configuration to WAF policy](https://learn.microsoft.com/azure/web-application-firewall/ag/upgrade-ag-waf-policy#upgrade-waf-v2-with-legacy-waf-configuration-to-waf-policy)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.network/applicationgateways)
