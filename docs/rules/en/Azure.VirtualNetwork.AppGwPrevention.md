---
severity: Critical
category: Security configuration
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en/Azure.VirtualNetwork.AppGwPrevention.md
---

# Azure.VirtualNetwork.AppGwPrevention

## SYNOPSIS

Internet exposed Application Gateways should use prevention mode to protect backend resources.

## DESCRIPTION

Application Gateways with Web Application Firewall (WAF) enabled support two modes of operation, detection and prevention.

- Detection - monitors and logs all threat alerts. In this mode, the web application firewall doesn't block incoming requests.
- Protection - blocks intrusions and attacks that the rules detect.

## RECOMMENDATION

Consider switching Internet exposed Application Gateways to use prevention mode to protect backend resources.

For more information see [Application Gateway WAF modes](https://docs.microsoft.com/en-us/azure/application-gateway/waf-overview#waf-modes).
