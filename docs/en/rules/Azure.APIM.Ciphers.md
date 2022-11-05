---
severity: Important
pillar: Security
category: Data protection
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.Ciphers/
---

# Use secure protocols

## SYNOPSIS

API Management should not accept weak or deprecated ciphers.

## DESCRIPTION

API Management provides support for weak or deprecated ciphers.
These older versions are provided for compatibility but are not consider secure.
These Ciphers are enabled by default and need to be set to False.

## RECOMMENDATION

Consider disabling weak or deprecated ciphers.

## LINKS

- [Data encryption in Azure](https://learn.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Manage protocols and ciphers in Azure API Management](https://docs.microsoft.com/azure/api-management/api-management-howto-manage-protocols-ciphers)
- [Cryptographic Recommendations](https://docs.microsoft.com/security/sdl/cryptographic-recommendations)
