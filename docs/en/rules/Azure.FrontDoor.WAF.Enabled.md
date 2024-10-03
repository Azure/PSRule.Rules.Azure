---
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoor.WAF.Enabled/
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

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Securing PaaS deployments](https://learn.microsoft.com/azure/security/fundamentals/paas-deployments#install-a-web-application-firewall)
- [Policy settings for Web Application Firewall on Azure Front Door](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-policy-settings#waf-state)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/frontdoorwebapplicationfirewallpolicies)
