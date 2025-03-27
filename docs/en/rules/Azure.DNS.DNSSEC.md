---
reviewed: 2025-03-27
severity: Important
pillar: Security
category: SE:08 Hardening resources
resource: Azure DNS
resourceType: Microsoft.Network/dnsZones,Microsoft.Network/dnsZones/dnssecConfigs
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.DNS.DNSSEC/
---

# DNS Zone is not signed

## SYNOPSIS

DNS may be vulnerable to several attacks when the DNS clients are not able to verify the authenticity of the DNS responses.

## DESCRIPTION

Domain Name System (DNS) typically operates over an unencrypted channel, in which DNS queries and responses are sent in plaintext.
If an attacker can intercept the DNS queries and responses, they can redirect users to malicious sites or perform other attacks.
These attacks are known as DNS spoofing or man-in-the-middle and may also include DNS cache poisoning.

Modern DNS clients support DNSSEC (Domain Name System Security Extensions),
which uses cryptographic signatures and a chain of trust to ensure the authenticity and integrity of DNS responses.
This enables DNS clients to verify that the DNS response they receive for a zone is authentic and has not been tampered with.

Azure Public DNS zones support DNSSEC, however it is not enabled by default.
Additionally, once DNSSEC is enabled, DS records must be created in the parent zone to establish a chain of trust.
See the reference links for more information on how to complete

## RECOMMENDATION

Consider enabling DNSSEC in Azure Public DNS zones to allow clients to verify the authenticity and integrity of responses.

## EXAMPLES

### Configure with Bicep

To deploy Azure DNS zones that pass this rule:

- Create a `Microsoft.Network/dnsZones/dnssecConfigs` sub-resource with the name `default` under the parent zone.

For example:

```bicep
resource dnssec 'Microsoft.Network/dnsZones/dnssecConfigs@2023-07-01-preview' = {
  parent: zone
  name: 'default'
}
```

### Configure with Azure template

To deploy Azure DNS zones that pass this rule:

- Create a `Microsoft.Network/dnsZones/dnssecConfigs` sub-resource with the name `default` under the parent zone.

For example:

```json
{
  "type": "Microsoft.Network/dnsZones/dnssecConfigs",
  "apiVersion": "2023-07-01-preview",
  "name": "[format('{0}/{1}', parameters('name'), 'default')]",
  "dependsOn": [
    "[resourceId('Microsoft.Network/dnsZones', parameters('name'))]"
  ]
}
```

### Configure with Azure CLI

```bash
az network dns dnssec-config create -z '<name>' -g '<resource_group>'
```

## NOTES

This rule only applies to Azure Public DNS zones.

## LINKS

- [SE:08 Hardening resources](https://learn.microsoft.com/azure/well-architected/security/harden-resources)
- [DNSSEC overview](https://learn.microsoft.com/azure/dns/dnssec)
- [DNSSEC – What Is It and Why Is It Important?](https://www.icann.org/resources/pages/dnssec-what-is-it-why-important-2019-03-05-en)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/dnszones/dnssecconfigs)
