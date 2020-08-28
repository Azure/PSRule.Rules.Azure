---
severity: Important
pillar: Security
category: Encryption
resource: Content Delivery Network
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.CDN.HTTP.md
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

- [Configure HTTPS on an Azure CDN custom domain](https://docs.microsoft.com/en-us/azure/cdn/cdn-custom-ssl?tabs=option-1-default-enable-https-with-a-cdn-managed-certificate)
