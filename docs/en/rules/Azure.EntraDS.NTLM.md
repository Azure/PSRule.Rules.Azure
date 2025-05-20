---
reviewed: 2024-04-27
severity: Critical
pillar: Security
category: SE:07 Encryption
resource: Entra Domain Services
resourceType: Microsoft.AAD/domainServices
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EntraDS.NTLM/
---

# Entra Domain Services allows insecure version of NTLM

## SYNOPSIS

Disable NTLM v1 for Microsoft Entra Domain Services.

## DESCRIPTION

By default, Microsoft Entra Domain Services enables the use of ciphers and protocols such as NTLM v1.
These ciphers may be required for some legacy applications, but are considered weak and can be disabled if not required.

## RECOMMENDATION

Consider disabling NTLM v1 which is considered weak and can be disabled if not required.

## EXAMPLES

### Configure with Bicep

To deploy domains that pass this rule:

- Set the `properties.domainSecuritySettings.ntlmV1` property to `Disabled`.

For example:

```bicep
resource ds 'Microsoft.AAD/domainServices@2022-12-01' = {
  name: name
  location: location
  properties: {
    sku: 'Enterprise'
    ldapsSettings: {
      ldaps: 'Enabled'
    }
    domainSecuritySettings: {
      ntlmV1: 'Disabled'
      tlsV1: 'Disabled'
      kerberosRc4Encryption: 'Disabled'
    }
    replicaSets: [
      {
        subnetId: primarySubnetId
        location: location
      }
      {
        subnetId: secondarySubnetId
        location: secondaryLocation
      }
    ]
  }
}
```

<!-- external:avm avm/res/aad/domain-service ntlmV1 -->

### Configure with Azure template

To deploy domains that pass this rule:

- Set the `properties.domainSecuritySettings.ntlmV1` property to `Disabled`.

For example:

```json
{
  "type": "Microsoft.AAD/domainServices",
  "apiVersion": "2022-12-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "sku": "Enterprise",
    "ldapsSettings": {
      "ldaps": "Enabled"
    },
    "domainSecuritySettings": {
      "ntlmV1": "Disabled",
      "tlsV1": "Disabled",
      "kerberosRc4Encryption": "Disabled"
    },
    "replicaSets": [
      {
        "subnetId": "[parameters('primarySubnetId')]",
        "location": "[parameters('location')]"
      },
      {
        "subnetId": "[parameters('secondarySubnetId')]",
        "location": "[parameters('secondaryLocation')]"
      }
    ]
  }
}
```

## LINKS

- [SE:07 Encryption](https://learn.microsoft.com/azure/well-architected/security/encryption)
- [Harden a Microsoft Entra Domain Services managed domain](https://learn.microsoft.com/entra/identity/domain-services/secure-your-domain)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.aad/domainservices)
