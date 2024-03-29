---
reviewed: 2022-09-20
severity: Critical
pillar: Security
category: Network security and containment
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoorWAF.Enabled/
---

# Enable Front Door WAF policy

## SYNOPSIS

Front Door Web Application Firewall (WAF) policy must be enabled to protect back end resources.

## DESCRIPTION

The operational state of a Front Door WAF policy instance is configurable, either enabled or disabled.
By default, a WAF policy is enabled.

When disabled, incoming requests bypass the WAF policy and are sent to back ends based on routing rules.

## RECOMMENDATION

Consider enabling WAF policy.

## EXAMPLES

### Configure with Azure template

To deploy WAF policies that pass this rule:

- Set the `properties.policySettings.enabledState` property to `Enabled`.

For example:

```json
{
  "type": "Microsoft.Network/FrontDoorWebApplicationFirewallPolicies",
  "apiVersion": "2022-05-01",
  "name": "[parameters('name')]",
  "location": "Global",
  "sku": {
    "name": "Premium_AzureFrontDoor"
  },
  "properties": {
    "managedRules": {
      "managedRuleSets": [
        {
          "ruleSetType": "Microsoft_DefaultRuleSet",
          "ruleSetVersion": "2.0",
          "ruleSetAction": "Block",
          "exclusions": [],
          "ruleGroupOverrides": []
        },
        {
          "ruleSetType": "Microsoft_BotManagerRuleSet",
          "ruleSetVersion": "1.0",
          "ruleSetAction": "Block",
          "exclusions": [],
          "ruleGroupOverrides": []
        }
      ]
    },
    "policySettings": {
      "enabledState": "Enabled",
      "mode": "Prevention"
    }
  }
}
```

### Configure with Bicep

To deploy WAF policies that pass this rule:

- Set the `properties.policySettings.enabledState` property to `Enabled`.

For example:

```bicep
resource waf 'Microsoft.Network/FrontDoorWebApplicationFirewallPolicies@2022-05-01' = {
  name: name
  location: 'Global'
  sku: {
    name: 'Premium_AzureFrontDoor'
  }
  properties: {
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.0'
          ruleSetAction: 'Block'
          exclusions: []
          ruleGroupOverrides: []
        }
        {
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: '1.0'
          ruleSetAction: 'Block'
          exclusions: []
          ruleGroupOverrides: []
        }
      ]
    }
    policySettings: {
      enabledState: 'Enabled'
      mode: 'Prevention'
    }
  }
}
```

## LINKS

- [Best practices for endpoint security on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [Securing PaaS deployments](https://learn.microsoft.com/azure/security/fundamentals/paas-deployments#install-a-web-application-firewall)
- [Policy settings for Web Application Firewall on Azure Front Door](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-policy-settings#waf-state)
- [Web Application Firewall best practices](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-best-practices)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/frontdoorwebapplicationfirewallpolicies)
