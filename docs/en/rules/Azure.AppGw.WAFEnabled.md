---
severity: Critical
pillar: Security
category: Network security and containment
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.WAFEnabled/
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

## LINKS

- [Best practices for endpoint security on Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-network-endpoints)
- [Securing PaaS deployments](https://docs.microsoft.com/azure/security/fundamentals/paas-deployments#install-a-web-application-firewall)
- [What is Azure Web Application Firewall on Azure Application Gateway?](https://docs.microsoft.com/azure/web-application-firewall/ag/ag-overview)
