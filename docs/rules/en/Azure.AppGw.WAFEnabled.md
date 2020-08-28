---
severity: Critical
pillar: Security
category: Network security and containment
resource: Application Gateway
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AppGw.WAFEnabled.md
---

# Application Gateway WAF is enabled

## SYNOPSIS

Application Gateway Web Application Firewall (WAF) must be enabled to protect backend resources.

## DESCRIPTION

Security features of Application Gateways deployed with WAF may be toggled on or off.

When WAF is disabled network traffic is still processed by the Application Gateway however detection and/ or prevention of malicious attacks does not occur.

To protect backend resources from potentially malicious network traffic, WAF must be enabled.

## RECOMMENDATION

Consider enabling WAF for Application Gateway instances connected to un-trusted or low-trust networks such as the Internet.
