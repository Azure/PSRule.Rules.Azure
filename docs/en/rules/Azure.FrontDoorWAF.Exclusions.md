---
reviewed: 2022-09-20
severity: Critical
pillar: Security
category: Network security and containment
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

## LINKS

- [Best practices for endpoint security on Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [Securing PaaS deployments](https://docs.microsoft.com/azure/security/fundamentals/paas-deployments#install-a-web-application-firewall)
- [Policy settings for Web Application Firewall on Azure Front Door](https://docs.microsoft.com/azure/web-application-firewall/afds/waf-front-door-policy-settings#waf-mode)
- [Web Application Firewall CRS rule groups and rules](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules)
- [Bot protection overview](https://learn.microsoft.com/en-us/azure/web-application-firewall/ag/bot-protection-overview)
- [Web Application Firewall best practices](https://learn.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-best-practices)
