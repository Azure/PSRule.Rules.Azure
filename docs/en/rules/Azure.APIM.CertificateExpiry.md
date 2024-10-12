---
severity: Important
pillar: Reliability
category: RE:04 Target metrics
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

### Rule configuration

<!-- module:config rule AZURE_APIM_MINIMUM_CERTIFICATE_LIFETIME -->

By default, this rule fails if the days before a configured certificate expires is less than 30 days.
To configure this rule,
override the `AZURE_APIM_MINIMUM_CERTIFICATE_LIFETIME` configuration value with the minimum number of days until expiry.

## LINKS

- [RE:04 Target metrics](https://learn.microsoft.com/azure/well-architected/reliability/metrics)
- [Configure a custom domain name](https://learn.microsoft.com/azure/api-management/configure-custom-domain#use-the-azure-portal-to-set-a-custom-domain-name)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.apimanagement/2019-12-01/service#hostnameconfiguration-object)
