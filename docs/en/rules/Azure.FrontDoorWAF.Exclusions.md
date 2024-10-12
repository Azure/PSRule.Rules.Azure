---
reviewed: 2022-09-20
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoorWAF.Exclusions/
---

# Avoid configuring Front Door WAF rule exclusions

## SYNOPSIS

Use recommended rule groups in Front Door Web Application Firewall (WAF) policies to protect back end resources.
Avoid configuring rule exclusions.

## DESCRIPTION

Front Door WAF supports exclusions lists.

Sometimes Web Application Firewall (WAF) might block a request that you want to allow for your application.
WAF exclusion lists allow you to omit certain request attributes from a WAF evaluation.
However, it should be allowed and only used as a last resort.

## RECOMMENDATION

Avoid configuring Front Door WAF rule exclusions.

## EXAMPLES

### Configure with Azure template

To deploy WAF policies that pass this rule:

- Remove any rule exclusions by:
  - Set the `exclusions` property for each managed rule group to an empty array. **OR**
  - Remove the `exclusions` property for each managed rule group.

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

- Remove any rule exclusions by:
  - Set the `exclusions` property for each managed rule group to an empty array. **OR**
  - Remove the `exclusions` property for each managed rule group.

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

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Securing PaaS deployments](https://learn.microsoft.com/azure/security/fundamentals/paas-deployments#install-a-web-application-firewall)
- [Policy settings for Web Application Firewall on Azure Front Door](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-policy-settings#waf-mode)
- [Web Application Firewall CRS rule groups and rules](https://learn.microsoft.com/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules)
- [Bot protection overview](https://learn.microsoft.com/azure/web-application-firewall/ag/bot-protection-overview)
- [Web Application Firewall best practices](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-best-practices)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/frontdoorwebapplicationfirewallpolicies)
