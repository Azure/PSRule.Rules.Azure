---
reviewed: 2025-05-19
severity: Important
pillar: Reliability
category: RE:05 High-availability multi-region design
resource: Entra Domain Services
resourceType: Microsoft.AAD/domainServices
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EntraDS.SKU/
---

# Entra Domain Services uses minimum SKU

## SYNOPSIS

The default SKU for Microsoft Entra Domain Services supports resiliency in a single region.

## DESCRIPTION

By default, Microsoft Entra Domain Services (Azure AD DS) deploys a replica set in a single region.
When using the `Standard` SKU, only a single replica set is supported.
To deploy a replica set across multiple regions, a minimum of the `Enterprise` SKU must be used.
Both the `Enterprise` and `Premium` SKUs support cross-region replication.

Deploying a replica set in multiple regions provides resiliency against region failures for this identity service.
Even if multiple regions is not required for supporting running applications across multiple regions,
it is often a requirement for disaster recovery.

## RECOMMENDATION

Consider using a minimum `Enterprise` SKU to support resiliency across multiple regions.

## EXAMPLES

### Configure with Bicep

To deploy domains that pass this rule:

- Set the `properties.sku` property to `Enterprise` or `Premium`.

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

<!-- external:avm avm/res/aad/domain-service sku -->

### Configure with Azure template

To deploy domains that pass this rule:

- Set the `properties.sku` property to `Enterprise` or `Premium`.

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

- [RE:05 High-availability multi-region design](https://learn.microsoft.com/azure/well-architected/reliability/highly-available-multi-region-design)
- [Change the SKU for an existing Microsoft Entra Domain Services managed domain](https://learn.microsoft.com/entra/identity/domain-services/change-sku)
- [Tutorial: Create and use replica sets for resiliency or geolocation in Microsoft Entra Domain Services](https://learn.microsoft.com/entra/identity/domain-services/tutorial-create-replica-set)
- [Azure Proactive Resiliency Library v2](https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/AAD/domainServices/#use-at-least-the-enterprise-sku)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.aad/domainservices)
