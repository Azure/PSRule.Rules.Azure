---
reviewed: 2024-04-27
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: Entra Domain Services
resourceType: Microsoft.AAD/domainServices
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EntraDS.TLS/
---

# Disable TLS v1

## SYNOPSIS

Disable TLS v1 for Microsoft Entra Domain Services.

## DESCRIPTION

By default, Microsoft Entra Domain Services enables the use of ciphers and protocols such as TLS v1.
These ciphers may be required for some legacy applications, but are considered weak and can be disabled if not required.

Older TLS versions such as 1.0 and 1.1 are no longer considered secure by industry standards, such as PCI DSS.

## RECOMMENDATION

Consider disabling TLS v1 which is considered weak and can be disabled if not required.

## EXAMPLES

### Configure with Azure template

To deploy domains that pass this rule:

- Set the `properties.domainSecuritySettings.tlsV1` property to `Disabled`.

For example:

```json
{
  "type": "Microsoft.AAD/domainServices",
  "apiVersion": "2022-12-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "ldapsSettings": {
      "ldaps": "Enabled"
    },
    "domainSecuritySettings": {
      "ntlmV1": "Disabled",
      "tlsV1": "Disabled",
      "kerberosRc4Encryption": "Disabled"
    }
  }
}
```

### Configure with Bicep

To deploy domains that pass this rule:

- Set the `properties.domainSecuritySettings.tlsV1` property to `Disabled`.

For example:

```bicep
resource ds 'Microsoft.AAD/domainServices@2022-12-01' = {
  name: name
  location: location
  properties: {
    ldapsSettings: {
      ldaps: 'Enabled'
    }
    domainSecuritySettings: {
      ntlmV1: 'Disabled'
      tlsV1: 'Disabled'
      kerberosRc4Encryption: 'Disabled'
    }
  }
}
```

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption)
- [Harden a Microsoft Entra Domain Services managed domain](https://learn.microsoft.com/entra/identity/domain-services/secure-your-domain)
- [DP-3: Encrypt sensitive data in transit](https://learn.microsoft.com/security/benchmark/azure/baselines/azure-active-directory-domain-services-security-baseline#dp-3-encrypt-sensitive-data-in-transit)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.aad/domainservices)
