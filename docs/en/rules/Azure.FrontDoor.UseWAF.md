---
severity: Critical
pillar: Security
category: SE:06 Network controls
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoor.UseWAF/
---

# Front Door endpoints should use WAF

## SYNOPSIS

Enable Web Application Firewall (WAF) policies on each Front Door endpoint.

## DESCRIPTION

Front Door endpoints can optionally be configured with a WAF policy.
When configured, every incoming request through Front Door is filtered by the WAF policy.

## RECOMMENDATION

Consider enabling a WAF policy on each Front Door endpoint.

## LINKS

- [SE:06 Network controls](https://learn.microsoft.com/azure/well-architected/security/networking)
- [Securing PaaS deployments](https://learn.microsoft.com/azure/security/fundamentals/paas-deployments#install-a-web-application-firewall)
- [Azure Web Application Firewall on Azure Front Door](https://learn.microsoft.com/azure/web-application-firewall/afds/afds-overview)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/frontdoors/frontendendpoints)
