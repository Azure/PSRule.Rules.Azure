---
severity: Important
pillar: Security
category: SE:07 Encryption
resource: Content Delivery Network
resourceType: Microsoft.Cdn/profiles/endpoints
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.CDN.HTTP/
---

# CDN endpoint allows unencrypted traffic

## SYNOPSIS

Unencrypted communication could allow disclosure of information to an untrusted party.

## DESCRIPTION

When a client connect to CDN content it can use HTTP or HTTPS.
Support for both HTTP and HTTPS is enabled by default.
When using HTTP, sensitive information may be exposed to an untrusted party.

## RECOMMENDATION

Consider disabling HTTP support on the CDN endpoint origin.

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption#encrypt-data-in-transit)
- [Configure HTTPS on an Azure CDN custom domain](https://learn.microsoft.com/azure/cdn/cdn-custom-ssl)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cdn/profiles/endpoints)
