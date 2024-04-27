---
reviewed: 2024-04-27
severity: Awareness
pillar: Operational Excellence
category: OE:05 Infrastructure as code
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.ResourceLocation/
---

# Use a location parameter for regional resources

## SYNOPSIS

Resource locations should be an expression or `global`.

## DESCRIPTION

The `location` property is a required property for most Azure resources.
For non-regional resources such as Front Door and DNS Zones specify a literal location `global` instead.

The resource `location` determines where the resource configuration is stored and managed from.
Commonly this will also indicate which region your data is stored in.

When defining resources in Bicep or ARM templates, avoid hardcoding the location value, even when you know the location.
The location value should be a parameter what can be easily set or overridden when deploying the template.
This makes the template more flexible and reusable across different environments as requirements change.

Reusable templates and modules may include different resources that are deployed to different locations.
Define a `location` parameter value for resources that are likely to be in the same location.
This approach minimizes the number of times users are asked to provide location information.
For resources that aren't available in all locations, use a separate parameter.

Use Azure Policy to enforce the location of resources in your environment at runtime.

## RECOMMENDATION

Consider updating the resource `location` property to use a parameter to make templates and modules more flexible and reusable.

## EXAMPLES

### Configure with Azure template

To deploy resources that pass this rule:

- Set the `location` property to a parameter or `global`.

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

To define a location parameter:

- Under the `parameters` template property define a `string` sub-property.

For example:

```json
{
  "parameters": {
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "The location resources will be deployed."
      }
    }
  }
}
```

### Configure with Bicep

To deploy resources that pass this rule:

- Set the `location` property to a parameter or `global`.

For example:

```bicep
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

To define a location parameter:

- Use the `param` keyword.

For example:

```bicep
@description('The location resources will be deployed.')
param location string = resourceGroup().location
```

## NOTES

By default, the Bicep linter rule `no-hardcoded-location` will raise a warning if a resource location is hardcoded.

## LINKS

- [OE:05 Infrastructure as code](https://learn.microsoft.com/azure/well-architected/operational-excellence/infrastructure-as-code-design)
- [Bicep parameters](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Linter rule - no hardcoded locations](https://learn.microsoft.com/azure/azure-resource-manager/bicep/linter-rule-no-hardcoded-location)
- [ARM template best practices](https://learn.microsoft.com/azure/azure-resource-manager/templates/best-practices#location-recommendations-for-parameters)
- [ARM parameters](https://learn.microsoft.com/azure/azure-resource-manager/templates/syntax#parameters)
