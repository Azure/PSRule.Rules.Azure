---
severity: Important
pillar: Security
category: Encryption
resource: Content Delivery Network
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.CDN.MinTLS.md
---

# Azure CDN endpoint minimum TLS version

## SYNOPSIS

Azure CDN endpoints should reject TLS versions older than 1.2.

## DESCRIPTION

The minimum version of TLS that Azure CDN endpoints accept is configurable.
Older TLS versions are no longer considered secure by industry standards, such as PCI DSS.

Azure lets you disable outdated protocols and require connections to use a minimum of TLS 1.2.
By default, TLS 1.0, TLS 1.1, and TLS 1.2 is accepted.

To configure the minimum TLS version, a custom domain must be configured.

## RECOMMENDATION

Consider configuring a custom domain and setting the minimum supported TLS version to be 1.2.

## LINKS

- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/en-us/updates/azuretls12/)
- [REST API Custom Domains - Enable Custom Https](https://docs.microsoft.com/en-us/rest/api/cdn/customdomains/enablecustomhttps#minimumtlsversion)
