---
severity: Critical
pillar: Security
category: Data protection
resource: Application Gateway
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppGw.SSLPolicy/
---

# Application Gateways use a minimum TLS 1.2

## SYNOPSIS

Application Gateway should only accept a minimum of TLS 1.2.

## DESCRIPTION

Application Gateway should only accept a minimum of TLS 1.2.

## RECOMMENDATION

Consider configuring Application Gateway to accept a minimum of TLS 1.2.

## LINKS

- [Data encryption in Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Application Gateway SSL policy overview](https://docs.microsoft.com/azure/application-gateway/application-gateway-ssl-policy-overview)
- [Configure SSL policy versions and cipher suites on Application Gateway](https://docs.microsoft.com/azure/application-gateway/application-gateway-configure-ssl-policy-powershell)
- [Overview of TLS termination and end to end TLS with Application Gateway](https://docs.microsoft.com/azure/application-gateway/ssl-overview)
