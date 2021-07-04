---
severity: Critical
pillar: Security
category: Encryption
resource: App Service
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppService.MinTLS/
ms-content-id: e19fbe7e-da05-47d4-8de1-2fdf52ada662
---

# App Service minimum TLS version

## SYNOPSIS

App Service should reject TLS versions older then 1.2.

## DESCRIPTION

The minimum version of TLS that Azure App Service accepts is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

App Service lets you disable outdated protocols and enforce TLS 1.2.
By default, a minimum of TLS 1.2 is enforced.

## RECOMMENDATION

Consider configuring the minimum supported TLS version to be 1.2.
Also consider using Azure Policy to audit or enforce this configuration.

## LINKS

- [Enforce TLS versions](https://docs.microsoft.com/azure/app-service/configure-ssl-bindings#enforce-tls-versions)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [Insecure protocols](https://docs.microsoft.com/Azure/app-service/overview-security#insecure-protocols-http-tls-10-ftp)
