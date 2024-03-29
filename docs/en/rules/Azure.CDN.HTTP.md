---
severity: Important
pillar: Security
category: Data protection
resource: Content Delivery Network
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.CDN.HTTP/
---

# Use HTTPS client connections

## SYNOPSIS

Enforce HTTPS for client connections.

## DESCRIPTION

When a client connect to CDN content it can use HTTP or HTTPS.
Support for both HTTP and HTTPS is enabled by default.
When using HTTP, sensitive information may be exposed to an untrusted party.

## RECOMMENDATION

Consider disabling HTTP support on the CDN endpoint origin.

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Configure HTTPS on an Azure CDN custom domain](https://learn.microsoft.com/azure/cdn/cdn-custom-ssl?tabs=option-1-default-enable-https-with-a-cdn-managed-certificate)
