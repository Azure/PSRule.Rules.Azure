---
reviewed: 2025-10-28
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Application Gateway
resourceType: Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGwWAF.RuleGroups/
---

# Use Recommended Application Gateway WAF policy rule groups

## SYNOPSIS

Application Gateway WAF policies should include both Microsoft Default Rule Set and Bot Manager Rule Set to provide
comprehensive protection against web application threats and malicious bot traffic.

## DESCRIPTION

Application Gateway Web Application Firewall (WAF) policies require two managed rule sets to provide
comprehensive security coverage for web applications:

- Microsoft Default Rule Set 2.1 or later.
- Microsoft Bot Manager Rule Set 1.0 or later.

The Microsoft Default Rule Set provides protection against the most common web application vulnerabilities and attacks.
This rule set is based on industry-standard security patterns and includes:

- Protection against OWASP Top 10 vulnerabilities.
- SQL injection attack prevention.
- Cross-site scripting (XSS) protection.
- Local file inclusion (LFI) and remote file inclusion (RFI) protection.
- Protocol violation detection.

The Bot Manager Rule Set provides automated protection against malicious bot traffic and includes:

- Known bad bot detection and blocking.
- Rate limiting for suspicious traffic patterns.
- Protection against automated attacks and scraping.
- Integration with Microsoft threat intelligence.

## RECOMMENDATION

Consider using both Microsoft Default Rule Set and Microsoft Bot Manager Rule Set in your WAF policy
to ensure comprehensive protection against web attacks and malicious bot traffic.

## EXAMPLES

### Configure with Bicep

To deploy WAF policies that pass this rule:

- Add following managed rules sets by specifying the `properties.managedRules.managedRuleSets` property:
  - Add the `Microsoft_DefaultRuleSet` version `2.1` or later.
  - Add the `Microsoft_BotManagerRuleSet` version `1.0` or later.

For example:

```bicep
resource waf 'Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies@2024-10-01' = {
  name: name
  location: location
  properties: {
    managedRules: {
      managedRuleSets: [
        {
          ruleSetType: 'Microsoft_DefaultRuleSet'
          ruleSetVersion: '2.1'
        }
        {
          ruleSetType: 'Microsoft_BotManagerRuleSet'
          ruleSetVersion: '1.1'
        }
      ]
    }
    policySettings: {
      state: 'Enabled'
      mode: 'Prevention'
    }
  }
}
```

<!-- external:avm avm/res/network/application-gateway-web-application-firewall-policy managedRules -->

### Configure with Azure template

To deploy WAF policies that pass this rule:

- Add following managed rules sets by specifying the `properties.managedRules.managedRuleSets` property:
  - Add the `Microsoft_DefaultRuleSet` version `2.1` or later.
  - Add the `Microsoft_BotManagerRuleSet` version `1.0` or later.

For example:

```json
{
  "type": "Microsoft.Network/applicationGatewayWebApplicationFirewallPolicies",
  "apiVersion": "2024-10-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "managedRules": {
      "managedRuleSets": [
        {
          "ruleSetType": "Microsoft_DefaultRuleSet",
          "ruleSetVersion": "2.1"
        },
        {
          "ruleSetType": "Microsoft_BotManagerRuleSet",
          "ruleSetVersion": "1.1"
        }
      ]
    },
    "policySettings": {
      "state": "Enabled",
      "mode": "Prevention"
    }
  }
}
```

## NOTES

This rule requires both rule sets to be configured at minimum version in the WAF policy's managed rules section.
The rule sets work together to provide layered security protection for your web applications.

- For `Microsoft_DefaultRuleSet` use version `2.1` or later.
- For `Microsoft_BotManagerRuleSet` use version `1.0` or later.

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Security: Level 2](https://learn.microsoft.com/azure/well-architected/security/maturity-model?tabs=level2)
- [Securing PaaS deployments](https://learn.microsoft.com/azure/security/fundamentals/paas-deployments#install-a-web-application-firewall)
- [Web Application Firewall DRS rule groups and rules](https://learn.microsoft.com/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules)
- [Bot protection overview](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-policy-configure-bot-protection)
- [Web Application Firewall best practices](https://learn.microsoft.com/azure/web-application-firewall/ag/best-practices)
- [Configure WAF policies for Application Gateway](https://learn.microsoft.com/azure/web-application-firewall/ag/create-waf-policy-ag)
- [Monitor Application Gateway WAF](https://learn.microsoft.com/azure/web-application-firewall/ag/application-gateway-waf-metrics)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/applicationgatewaywebapplicationfirewallpolicies)
