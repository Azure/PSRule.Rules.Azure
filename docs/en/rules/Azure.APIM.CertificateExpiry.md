---
severity: Important
pillar: Operational Excellence
category: Deployment
resource: API Management
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.APIM.CertificateExpiry/
---

# API Management uses current certificates

## SYNOPSIS

Renew certificates used for custom domain bindings.

## DESCRIPTION

When custom domains are configured within an API Management service.
A certificate must be assigned to allow traffic to be transmitted using TLS.

Each certificate has an expiry date, after which the certificate is not valid.
After expiry, client connections to the API Management service will reject the certificate.

## RECOMMENDATION

Consider renewing certificates before expiry to prevent service issues.

## NOTES

By default, this rule fails when certificates have less than 30 days remaining before expiry.

To configure this rule:

- Override the `Azure_MinimumCertificateLifetime` configuration value with the minimum number of days until expiry.

## LINKS

- [Configure a custom domain name](https://learn.microsoft.com/azure/api-management/configure-custom-domain#use-the-azure-portal-to-set-a-custom-domain-name)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/2019-12-01/service#hostnameconfiguration-object)
