---
reviewed: 2024-02-17
severity: Important
pillar: Security
category: SE:01 Security baseline
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Resource.AllowedRegions/
---

# Resource deployment location is not allowed

## SYNOPSIS

The deployment location of a resource determines the country or region where metadata and data is stored and processed.

## DESCRIPTION

Azure supports deployment to many locations around the world called regions.
Many organizations have requirements or legal obligations that limit where data can be stored or processed.
This is commonly known as data residency.

To align with your organizational requirements, you may choose to limit the regions that resources can be deployed to.
This allows you to ensure that resources are deployed to regions that meet your data residency requirements.

Some resources, particularly those related to preview services or features, may not be available in all regions.

## RECOMMENDATION

Consider deploying resources to allowed regions to align with your organizational requirements.
Also consider using Azure Policy to enforce allowed regions at runtime.

## EXAMPLES

### Configure with Azure template

To deploy resources that pass this rule:

- Set the `location` property to an allowed region. _OR_
- Instead of hard coding the location, use a parameter to allow the location to be specified at deployment time.

For example:

```json
{
  "type": "Microsoft.Storage/storageAccounts",
  "apiVersion": "2023-01-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "sku": {
    "name": "Standard_GRS"
  },
  "kind": "StorageV2",
  "properties": {
    "allowBlobPublicAccess": false,
    "supportsHttpsTrafficOnly": true,
    "minimumTlsVersion": "TLS1_2",
    "accessTier": "Hot",
    "allowSharedKeyAccess": false,
    "networkAcls": {
      "defaultAction": "Deny"
    }
  }
}
```

### Configure with Bicep

To deploy resources that pass this rule:

- Set the `location` property to an allowed region. _OR_
- Instead of hard coding the location, use a parameter to allow the location to be specified at deployment time.

For example:

```bicep
@sys.description('The location resources will be deployed.')
param location string = resourceGroup().location

resource storageAccount 'Microsoft.Storage/storageAccounts@2023-01-01' = {
  name: name
  location: location
  sku: {
    name: 'Standard_GRS'
  }
  kind: 'StorageV2'
  properties: {
    allowBlobPublicAccess: false
    supportsHttpsTrafficOnly: true
    minimumTlsVersion: 'TLS1_2'
    accessTier: 'Hot'
    allowSharedKeyAccess: false
    networkAcls: {
      defaultAction: 'Deny'
    }
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
- [Data residency in Azure](https://azure.microsoft.com/explore/global-infrastructure/data-residency/#overview)
- [Azure geographies](https://azure.microsoft.com/explore/global-infrastructure/geographies/#geographies)
