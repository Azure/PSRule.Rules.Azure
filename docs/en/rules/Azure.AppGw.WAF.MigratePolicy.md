---
severity: Critical
pillar: Reliability
category: RE:04 Target metrics
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.WAF.MigratePolicy/
---

# Migrate to Application Gateway WAF policy

## SYNOPSIS

Migrate to Application Gateway WAF policy.

## DESCRIPTION

App Gateway V2 supports two configuration modes for WAF:

- Reference an existing WAF policy reference via `properties.firewallPolicy.id`. This option is recommended.
- Specify the legacy WAF configuration via setting the `properties.webApplicationFirewallConfiguration`. This option is deprecated for retirement on 15 March 2027.


## RECOMMENDATION

Upgrade WAF v2 with legacy WAF configuration to WAF policy.

## EXAMPLES

### Configure with Azure template

To deploy Application Gateways that pass this rule:

- Deploy an Application Gateway with the `WAF_v2` SKU.
- Configure the `properties.firewallPolicy.id` property and don't specify the legacy `properties.webApplicationFirewallConfiguration` property.

For example:

```json
{
    "name": "[parameters('name')]",
    "type": "Microsoft.Network/applicationGateways",
    "apiVersion": "2023-11-01",
    "location": "[resourceGroup().location]",
    "properties": {
        "sku": {
            "name": "WAF_v2",
            "tier": "WAF_v2"
        },
        "firewallPolicy": {
          "id": "[parameters('firewallPolicyId')]"
        }
    }
}
```

### Configure with Bicep

To deploy Application Gateways that pass this rule:

- Deploy an Application Gateway with the `WAF_v2` SKU.
- Configure the `properties.firewallPolicy.id` property and don't specify the legacy `properties.webApplicationFirewallConfiguration` property.

For example:

```bicep
resource agw 'Microsoft.Network/applicationGateways@2023-11-01' = {
  name: name
  location: location
  properties: {
    sku: {
      name: 'WAF_v2'
      tier: 'WAF_v2'
    }
    firewallPolicy: {
      id: firewallPolicyId
    }
  }
}
```

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Retirement: Support for Application Gateway Web Application Firewall v2 Configuration is ending](https://azure.microsoft.com/updates/retirement-support-for-application-gateway-web-application-firewall-v2-configuration-is-ending/)
- [Upgrade WAF v2 with legacy WAF configuration to WAF policy](https://learn.microsoft.com/azure/web-application-firewall/ag/upgrade-ag-waf-policy#upgrade-waf-v2-with-legacy-waf-configuration-to-waf-policy)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.network/applicationgateways)
