---
severity: Important
category: Security configuration
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.VirtualNetwork.AppGwWAFRules.md
---

# Azure.VirtualNetwork.AppGwWAFRules

## SYNOPSIS

Application Gateway Web Application Firewall (WAF) should have all rules enabled.

## DESCRIPTION

Application Gateway instances with WAF allow OWASP detection/ prevention rules to be toggled on or off. All OWASP rules are turned on by default.

When OWASP rules are turned off, the protection they provide is disabled.

## RECOMMENDATION

Consider enabling all OWASP rules within Application Gateway instances.

Before disabling OWASP rules, ensure that the backend workload has alternative protections in-place. Alternatively consider updating application code to use safe web standards.
