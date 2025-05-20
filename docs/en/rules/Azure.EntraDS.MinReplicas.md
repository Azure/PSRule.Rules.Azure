---
reviewed: 2025-05-19
severity: Important
pillar: Reliability
category: RE:05 High-availability multi-region design
resource: Entra Domain Services
resourceType: Microsoft.AAD/domainServices
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EntraDS.MinReplicas/
---

# Entra Domain Services is not replicated across multiple regions

## SYNOPSIS

Applications or infrastructure relying on a managed domain may fail if the domain is not available.

## DESCRIPTION

By default, Microsoft Entra Domain Services (previously Azure AD DS) deploys a replica set in a single region.
Which enables applications to use the managed domain for authentication and authorization.

To improve the resiliency and reduce latency of an application using a managed domain,
your can deploy a replica set in each region where the application is deployed that also supports Domain Services.

Deploying multiple replica sets in different regions provides resiliency against region failures for this identity service.
Even if multiple regions is not required for supporting running applications across multiple regions,
it is often a requirement for disaster recovery.

To configure cross-region replication, Domain Services requires a `Enterprise` or `Premium` SKU.
Additionally, there is some VNET configuration requirements to support cross-region replication.
See the documentation links below for more details.

## RECOMMENDATION

Consider deploying a replica set in two or more regions where applications relying on the managed domain are deployed.

## EXAMPLES

### Configure with Bicep

To deploy domains that pass this rule:

- Updated the `properties.replicaSets` property to include a replica set in each region where the application is deployed.
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

<!-- external:avm avm/res/aad/domain-service replicaSets -->

### Configure with Azure template

To deploy domains that pass this rule:

- Updated the `properties.replicaSets` property to include a replica set in each region where the application is deployed.
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
- [Replica sets concepts and features for Microsoft Entra Domain Services](https://learn.microsoft.com/entra/identity/domain-services/concepts-replica-sets)
- [Tutorial: Create and use replica sets for resiliency or geolocation in Microsoft Entra Domain Services](https://learn.microsoft.com/entra/identity/domain-services/tutorial-create-replica-set)
- [Tutorial: Perform a disaster recovery drill using replica sets in Microsoft Entra Domain Services](https://learn.microsoft.com/entra/identity/domain-services/tutorial-perform-disaster-recovery-drill)
- [Change the SKU for an existing Microsoft Entra Domain Services managed domain](https://learn.microsoft.com/entra/identity/domain-services/change-sku)
- [Azure Proactive Resiliency Library v2](https://azure.github.io/Azure-Proactive-Resiliency-Library-v2/azure-resources/AAD/domainServices/#use-replica-sets-for-resiliency-or-geolocation-in-microsoft-entra-domain-services)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.aad/domainservices)
