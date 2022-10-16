---
severity: Important
pillar: Security
category: Encryption
resource: Content Delivery Network
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.CDN.MinTLS/
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

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Preparing for TLS 1.2 in Microsoft Azure](https://azure.microsoft.com/updates/azuretls12/)
- [REST API Custom Domains - Enable Custom Https](https://docs.microsoft.com/rest/api/cdn/customdomains/enablecustomhttps#minimumtlsversion)
- [Azure deployment reference](https://docs.microsoft.com/azure/templates/microsoft.cdn/profiles/endpoints)
