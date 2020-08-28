---
severity: Critical
pillar: Security
category: Network security and containment
resource: Front Door
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.FrontDoor.WAF.Enabled.md
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

- [Policy settings for Web Application Firewall on Azure Front Door](https://docs.microsoft.com/en-us/azure/web-application-firewall/afds/waf-front-door-policy-settings#waf-state)
