---
reviewed: 2023-09-10
severity: Important
pillar: Security
category: Design
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Resource.AllowedRegions/
---

# Use allowed regions

## SYNOPSIS

Resources should be deployed to allowed regions.

## DESCRIPTION

Azure supports deployment to many locations around the world called regions.
Many organizations have requirements that limit where data can be stored or processed.
This is commonly known as data residency.

Most Azure resources must be deployed to a specific region.
To align with your organizational requirements, you may choose to limit the regions that resources can be deployed to.

Some resources, particularly those related to preview services or features, may not be available in all regions.

## RECOMMENDATION

Consider deploying resources to allowed regions to align with your organizational requirements.
Also consider using Azure Policy to enforce allowed regions.

## EXAMPLES

### Configure with Azure template

To deploy resources that pass this rule:

- Set the `location` property to an allowed region. OR
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

- Set the `location` property to an allowed region. OR
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

- [Regulatory compliance](https://learn.microsoft.com/azure/well-architected/security/design-regulatory-compliance)
- [Data residency in Azure](https://azure.microsoft.com/explore/global-infrastructure/data-residency/#overview)
- [Azure geographies](https://azure.microsoft.com/explore/global-infrastructure/geographies/#geographies)
