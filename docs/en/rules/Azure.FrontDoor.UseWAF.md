---
severity: Critical
pillar: Security
category: Network security and containment
resource: Front Door
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.FrontDoor.UseWAF/
---

# Front Door endpoints should use WAF

## SYNOPSIS

Enable Web Application Firewall (WAF) policies on each Front Door endpoint.

## DESCRIPTION

Front Door endpoint can optionally be configured with a WAF policy.
When configured, every incoming request through Front Door is filtered by the WAF policy.

## RECOMMENDATION

Consider enabling a WAF policy on each Front Door endpoint.

## LINKS

- [Best practices for endpoint security on Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [Securing PaaS deployments](https://docs.microsoft.com/azure/security/fundamentals/paas-deployments#install-a-web-application-firewall)
- [Azure Web Application Firewall on Azure Front Door](https://docs.microsoft.com/azure/web-application-firewall/afds/afds-overview)
