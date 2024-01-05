---
reviewed: 2024-01-04
severity: Critical
pillar: Security
category: Network security and containment
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGwWAF.RuleGroups/
---

# Use Recommended Application Gateway WAF policy rule groups

## SYNOPSIS

Use recommended rule groups in Application Gateway Web Application Firewall (WAF) policies to protect back end resources.

## DESCRIPTION

Application Gateway WAF policies support two main Rule Groups.

- OWASP - Application Gateway web application firewall (WAF) protects web applications from common vulnerabilities and exploits.
This is done through rules that are defined based on the OWASP core rule sets 3.2, 3.1, 3.0.
It is recommended to use the latest rule set.
- Bot protection - Enable a managed bot protection rule set to block or log requests from known malicious IP addresses.

## RECOMMENDATION

Consider configuring Application Gateway WAF policy to use the recommended rule sets.

## LINKS

- [Best practices for endpoint security on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [Securing PaaS deployments](https://learn.microsoft.com/azure/security/fundamentals/paas-deployments#install-a-web-application-firewall)
- [Web Application Firewall CRS rule groups and rules](https://learn.microsoft.com/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules)
- [Bot protection overview](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-policy-configure-bot-protection)
- [Web Application Firewall best practices](https://learn.microsoft.com/azure/web-application-firewall/ag/best-practices)
