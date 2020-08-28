---
severity: Critical
pillar: Security
category: Network security and containment
resource: Front Door
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.FrontDoor.UseWAF.md
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

- [Azure Web Application Firewall on Azure Front Door](https://docs.microsoft.com/en-us/azure/web-application-firewall/afds/afds-overview)
