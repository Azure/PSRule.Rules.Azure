---
severity: Important
pillar: Security
category: Data protection
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.Protocols/
---

# Use secure protocols

## SYNOPSIS

API Management should only accept a minimum of TLS 1.2.

## DESCRIPTION

API Management provides support for older TLS/ SSL protocols and ciphers, which are disabled by default.
These older versions are provided for compatibility but not consider secure.

## RECOMMENDATION

Consider disabling SSL 3.0/ TLS 1.0/ TLS 1.1/ Triple DES protocols and ciphers.

## LINKS

- [Data encryption in Azure](https://docs.microsoft.com/azure/architecture/framework/security/design-storage-encryption#data-in-transit)
- [Manage protocols and ciphers in Azure API Management](https://docs.microsoft.com/azure/api-management/api-management-howto-manage-protocols-ciphers)
