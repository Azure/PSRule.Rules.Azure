---
reviewed: 2022-09-20
severity: Critical
pillar: Security
category: Network security and containment
resource: Application Gateway
resourceType: Microsoft.Network/ApplicationGatewayWebApplicationFirewallPolicies
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGwWAF.PreventionMode/
---

# Use Application Gateway WAF policy in prevention mode

## SYNOPSIS

Use protection mode in Application Gateway Web Application Firewall (WAF) policies to protect back end resources.

## DESCRIPTION

Application Gateway WAF policies support two modes of operation, detection and prevention.
By default, prevention is configured.

- Detection - monitors and logs all requests which match a WAF rule.
In this mode, the WAF doesn't take action against incoming requests.
To log requests, diagnostics on the Application Gateway instance must be configured.
- Protection - log and takes action against requests which match a WAF rule.
The action to perform is configurable for each WAF rule.

## RECOMMENDATION

Consider setting Application Gateway WAF policy to use protection mode.

## LINKS

- [Best practices for endpoint security on Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [Securing PaaS deployments](https://learn.microsoft.com/azure/security/fundamentals/paas-deployments#install-a-web-application-firewall)
- [Web Application Firewall best practices](https://learn.microsoft.com/azure/web-application-firewall/ag/best-practices)
