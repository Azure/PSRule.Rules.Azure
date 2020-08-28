---
severity: Important
pillar: Security
category: Network security and containment
resource: Application Gateway
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.AppGw.OWASP.md
---

# Use OWASP 3.x rules

## SYNOPSIS

Application Gateway Web Application Firewall (WAF) should use OWASP 3.x rules.

## DESCRIPTION

Application Gateways deployed with WAF features support configuration of OWASP rule sets for detection and/ or prevention of malicious attacks.

Two rule set versions are available; OWASP 2.x and OWASP 3.x.

## RECOMMENDATION

Consider configuring Application Gateway instances to use use newer OWASP 3.x rules instead of 2.x rule set versions.
