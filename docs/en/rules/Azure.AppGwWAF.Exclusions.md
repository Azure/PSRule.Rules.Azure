---
reviewed: 2022-09-20
severity: Critical
pillar: Security
category: Network security and containment
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGwWAF.Exclusions/
---

# Application Gateway rules are enabled

## SYNOPSIS

Application Gateway Web Application Firewall (WAF) should have all rules enabled.

## DESCRIPTION

Application Gateway instances with WAF allow OWASP detection/ prevention rules to be toggled on or off.
All OWASP rules are turned on by default.

When OWASP rules are turned off, the protection they provide is disabled.

## RECOMMENDATION

Consider enabling all OWASP rules within Application Gateway instances.

Before disabling OWASP rules, ensure that the backend workload has alternative protections in-place.
Alternatively consider updating application code to use safe web standards.

## LINKS

- [Best practices for endpoint security on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [Securing PaaS deployments](https://learn.microsoft.com/azure/security/fundamentals/paas-deployments#install-a-web-application-firewall)
- [What is Azure Web Application Firewall on Azure Application Gateway?](https://learn.microsoft.com/azure/web-application-firewall/ag/ag-overview)
- [Web Application Firewall CRS rule groups and rules](https://learn.microsoft.com/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules)
- [Web Application Firewall best practices](https://learn.microsoft.com/azure/web-application-firewall/ag/best-practices)
