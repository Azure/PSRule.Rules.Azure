---
severity: Critical
category: Security configuration
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.VirtualNetwork.AppGwWAFEnabled.md
---

# Azure.VirtualNetwork.AppGwWAFEnabled

## SYNOPSIS

Application Gateway Web Application Firewall (WAF) must be enabled to protect backend resources.

## DESCRIPTION

Security features of Application Gateways deployed with WAF may be toggled on or off.

When WAF is disabled network traffic is still processed by the Application Gateway however detection and/ or prevention of malicious attacks does not occur.

To protect backend resources from potentially malicious network traffic, WAF must be enabled.

## RECOMMENDATION

Consider enabling WAF for Application Gateway instances connected to un-trusted or low-trust networks such as the Internet.
