---
severity: Critical
pillar: Security
category: Encryption
resource: API Management
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.APIM.HTTPBackend.md
---

# Use HTTPS backend connections

## SYNOPSIS

Use HTTPS for communication to backend services.

## DESCRIPTION

When API Management connects to the backend API it can use HTTP or HTTPS.
When using HTTP, sensitive information may be exposed to an untrusted party.

## RECOMMENDATION

Consider configuring only backend services configured with HTTPS-based URLs.
