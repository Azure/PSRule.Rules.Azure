---
severity: Important
pillar: Security
category: Encryption
resource: API Management
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.APIM.HTTPEndpoint.md
---

# Publish APIs through HTTPS connections

## SYNOPSIS

Enforce HTTPS for communication to API clients.

## DESCRIPTION

When an client connects to API Management it can use HTTP or HTTPS.
Each API can be configured to accept connection for HTTP and/ or HTTPS.
When using HTTP, sensitive information may be exposed to an untrusted party.

## RECOMMENDATION

Consider setting the each API to only accept HTTPS connections.
In the portal, this is done by configuring the HTTPS URL scheme.

## LINKS

- [Import and publish a back-end API](https://docs.microsoft.com/en-us/azure/api-management/import-api-from-oas#-import-and-publish-a-back-end-api)
