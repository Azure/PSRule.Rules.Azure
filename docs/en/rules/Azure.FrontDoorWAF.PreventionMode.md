---
reviewed: 2022-09-20
severity: Critical
pillar: Security
category: Network security and containment
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoorWAF.PreventionMode/
---

# Use Front Door WAF policy in prevention mode

## SYNOPSIS

Use protection mode in Front Door Web Application Firewall (WAF) policies to protect back end resources.

## DESCRIPTION

Front Door WAF policies support two modes of operation, detection and prevention.
By default, prevention is configured.

- Detection - monitors and logs all requests which match a WAF rule.
In this mode, the WAF doesn't take action against incoming requests.
To log requests, diagnostics on the Front Door instance must be configured.
- Protection - log and takes action against requests which match a WAF rule.
The action to perform is configurable for each WAF rule.

## RECOMMENDATION

Consider setting Front Door WAF policy to use protection mode.

## EXAMPLES

### Configure with Azure template

To deploy WAF policies that pass this rule:

- Set the `properties.policySettings.mode` property to `Prevention`.

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

- Set the `properties.policySettings.mode` property to `Prevention`.

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
- [Securing PaaS deployments](https://docs.microsoft.com/azure/security/fundamentals/paas-deployments#install-a-web-application-firewall)
- [Policy settings for Web Application Firewall on Azure Front Door](https://docs.microsoft.com/azure/web-application-firewall/afds/waf-front-door-policy-settings#waf-mode)
- [Web Application Firewall best practices](https://docs.microsoft.com/azure/web-application-firewall/afds/waf-front-door-best-practices)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/frontdoorwebapplicationfirewallpolicies)
