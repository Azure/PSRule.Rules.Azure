---
severity: Important
pillar: Security
category: Security operations
resource: Front Door
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.FrontDoor.Logs.md
---

# Audit Front Door access

## SYNOPSIS

Audit and monitor access through Front Door.

## DESCRIPTION

To capture network activity through Front Door, diagnostic settings must be configured.
When configuring diagnostics settings enable `FrontdoorAccessLog` logs.

Enable `FrontdoorWebApplicationFirewallLog` when web application firewall (WAF) policy is configured.

Management operations for Front Door is captured automatically within Azure Activity Logs.

## RECOMMENDATION

Consider configuring diagnostics setting to log network activity through Front Door.

## LINKS

- [Monitoring metrics and logs in Azure Front Door Service](https://docs.microsoft.com/en-us/azure/frontdoor/front-door-diagnostics#diagnostic-logging)
