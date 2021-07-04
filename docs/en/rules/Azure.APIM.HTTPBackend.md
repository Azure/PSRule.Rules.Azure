---
severity: Critical
pillar: Security
category: Encryption
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.HTTPBackend/
---

# Use HTTPS backend connections

## SYNOPSIS

Use HTTPS for communication to backend services.

## DESCRIPTION

When API Management connects to the backend API it can use HTTP or HTTPS.
When using HTTP, sensitive information may be exposed to an untrusted party.

## RECOMMENDATION

Consider configuring only backend services configured with HTTPS-based URLs.
