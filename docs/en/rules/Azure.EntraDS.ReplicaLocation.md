---
reviewed: 2025-05-20
severity: Important
pillar: Security
category: SE:01 Security baseline
resource: Entra Domain Services
resourceType: Microsoft.AAD/domainServices
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EntraDS.ReplicaLocation/
---

# Entra Domain Services replica location is not allowed

## SYNOPSIS

The location of a replica set determines the country or region where the data is stored and processed.

## DESCRIPTION

Azure supports deployment to many locations around the world called regions.
Many organizations have requirements or legal obligations that limit where data can be stored or processed.
This is commonly known as data residency.

Entra managed domains are deployed into a primary region and can be additionally replicated to additional regions.
Each of these regions is called a replica set, which both stores and processes data in that region.

To align with your organizational requirements, you may choose to limit the regions that replica sets can be deployed to.
This allows you to ensure that resources are deployed to regions that meet your data residency requirements.

Some resources, particularly those related to preview services or features, may not be available in all regions.

## RECOMMENDATION

Consider deploying Entra ID Domain Service replicas to allowed regions to align with your organizational requirements.
Also consider using Azure Policy to enforce allowed regions at runtime.

## EXAMPLES

### Configure with Bicep

To deploy domains that pass this rule:

- Set the `location` property of each replica set specified in `properties.replicaSets` to an allowed region.

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

<!-- external:avm avm/res/aad/domain-service replicaSets[*].location -->

### Configure with Azure template

To deploy domains that pass this rule:

- Set the `location` property of each replica set specified in `properties.replicaSets` to an allowed region.

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

## NOTES

This rule requires one or more allowed regions to be configured.
By default, all regions are allowed.

### Rule configuration

<!-- module:config rule AZURE_RESOURCE_ALLOWED_LOCATIONS -->

To configure this rule set the `AZURE_RESOURCE_ALLOWED_LOCATIONS` configuration value to a set of allowed regions.

For example:

```yaml
configuration:
  AZURE_RESOURCE_ALLOWED_LOCATIONS:
  - australiaeast
  - australiasoutheast
```

If you configure this `AZURE_RESOURCE_ALLOWED_LOCATIONS` configuration value,
also consider setting `AZURE_RESOURCE_GROUP` the configuration value to when resources use the location of the resource group.

For example:

```yaml
configuration:
  AZURE_RESOURCE_GROUP:
    location: australiaeast
```

## LINKS

- [SE:01 Security baseline](https://learn.microsoft.com/azure/well-architected/security/establish-baseline)
- [Tutorial: Create and use replica sets for resiliency or geolocation in Microsoft Entra Domain Services](https://learn.microsoft.com/entra/identity/domain-services/tutorial-create-replica-set)
- [Replica sets concepts and features for Microsoft Entra Domain Services](https://learn.microsoft.com/entra/identity/domain-services/concepts-replica-sets)
- [Data residency in Azure](https://azure.microsoft.com/explore/global-infrastructure/data-residency/#overview)
- [Azure geographies](https://azure.microsoft.com/explore/global-infrastructure/geographies/#geographies)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.aad/domainservices)
