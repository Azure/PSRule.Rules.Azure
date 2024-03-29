---
severity: Critical
pillar: Security
category: Network security and containment
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoor.WAF.Mode/
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

## LINKS

- [Best practices for endpoint security on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [Securing PaaS deployments](https://learn.microsoft.com/azure/security/fundamentals/paas-deployments#install-a-web-application-firewall)
- [Policy settings for Web Application Firewall on Azure Front Door](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-policy-settings#waf-mode)
