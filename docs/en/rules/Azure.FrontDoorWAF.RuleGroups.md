---
reviewed: 2022-09-20
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoorWAF.RuleGroups/
---

# Use Recommended Front Door WAF policy rule groups

## SYNOPSIS

Use recommended rule groups in Front Door Web Application Firewall (WAF) policies to protect back end resources.

## DESCRIPTION

Front Door WAF policies support two main Rule Groups.

- OWASP - Front Door web application firewall (WAF) protects web applications from common vulnerabilities and exploits.
This is done through rules that are defined based on the OWASP core rule sets 3.2, 3.1, 3.0.
It is recommended to use the latest rule set.
- Bot protection - Enable a managed bot protection rule set to block or log requests from known malicious IP addresses.

## RECOMMENDATION

Consider configuring Front Door WAF policy to use the recommended rule sets.

## EXAMPLES

### Configure with Azure template

To deploy WAF policies that pass this rule:

- Add the `Microsoft_DefaultRuleSet` rule set to the `properties.managedRules.managedRuleSets` property.
  - Use the rule set version `2.0` or greater.
- Add the `Microsoft_BotManagerRuleSet` rule set to the `properties.managedRules.managedRuleSets` property.
  - Use the rule set version `1.0` or greater.

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

- Add the `Microsoft_DefaultRuleSet` rule set to the `properties.managedRules.managedRuleSets` property.
  - Use the rule set version `2.0` or greater.
- Add the `Microsoft_BotManagerRuleSet` rule set to the `properties.managedRules.managedRuleSets` property.
  - Use the rule set version `1.0` or greater.

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
