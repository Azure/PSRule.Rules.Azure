---
severity: Important
category: Security configuration
online version: https://github.com/BernieWhite/PSRule.Rules.Azure/blob/master/docs/rules/en-US/Azure.AppService.MinTLS.md
---

# Use minimum TLS version

## SYNOPSIS

App Service should reject TLS versions older then 1.2.

## DESCRIPTION

The minimum version of TLS that Azure App Service accepts is configurable. Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

App Service lets you disable outdated protocols and enforce TLS 1.2. By default use of a minimum of TLS 1.2 is enforced.

## RECOMMENDATION

Consider configuring the minimum supported TLS version to be 1.2.

For more information see [Enforce TLS versions](https://docs.microsoft.com/en-us/Azure/app-service/app-service-web-tutorial-custom-ssl#enforce-tls-versions) and [insecure protocols](https://docs.microsoft.com/en-us/Azure/app-service/overview-security#insecure-protocols-http-tls-10-ftp).
