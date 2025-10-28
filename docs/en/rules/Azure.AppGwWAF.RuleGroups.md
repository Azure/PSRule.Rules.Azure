---
reviewed: 2025-10-28
severity: Critical
pillar: Security
category: Network security and containment
resource: Application Gateway
resourceType: Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGwWAF.RuleGroups/
---

# Use Recommended Application Gateway WAF policy rule groups

## SYNOPSIS

Application Gateway WAF policies should include both Microsoft Default Rule Set and Bot Manager Rule Set to provide
comprehensive protection against web application threats and malicious bot traffic.

## DESCRIPTION

Application Gateway Web Application Firewall (WAF) policies require two managed rule sets to provide
comprehensive security coverage for web applications:

### Microsoft Default Rule Set

The Microsoft Default Rule Set provides protection against the most common web application vulnerabilities and attacks.
This rule set is based on industry-standard security patterns and includes:

- Protection against OWASP Top 10 vulnerabilities
- SQL injection attack prevention
- Cross-site scripting (XSS) protection
- Local file inclusion (LFI) and remote file inclusion (RFI) protection
- Protocol violation detection

**Minimum version required:** 2.1 or later

### Microsoft Bot Manager Rule Set (Required)

The Bot Manager Rule Set provides automated protection against malicious bot traffic and includes:

- Known bad bot detection and blocking
- Rate limiting for suspicious traffic patterns
- Protection against automated attacks and scraping
- Integration with Microsoft threat intelligence

**Minimum version required:** 1.0 or later

### Rule Set Configuration

Both rule sets must be configured in the WAF policy's managed rules section.
The rule sets work together to provide layered security protection for your web applications.

## RECOMMENDATION

Consider using both Microsoft Default Rule Set and Microsoft Bot Manager Rule Set in your WAF policy to ensure comprehensive protection against web attacks and malicious bot traffic.

## LINKS

- [Best practices for endpoint security on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [Securing PaaS deployments](https://learn.microsoft.com/azure/security/fundamentals/paas-deployments#install-a-web-application-firewall)
- [Web Application Firewall DRS rule groups and rules](https://learn.microsoft.com/azure/web-application-firewall/ag/application-gateway-crs-rulegroups-rules)
- [Bot protection overview](https://learn.microsoft.com/azure/web-application-firewall/afds/waf-front-door-policy-configure-bot-protection)
- [Web Application Firewall best practices](https://learn.microsoft.com/azure/web-application-firewall/ag/best-practices)
- [Configure WAF policies for Application Gateway](https://learn.microsoft.com/azure/web-application-firewall/ag/create-waf-policy-ag)
- [Monitor Application Gateway WAF](https://learn.microsoft.com/azure/web-application-firewall/ag/application-gateway-waf-metrics)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/applicationgateways)
