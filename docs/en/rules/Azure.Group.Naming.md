---
reviewed: 2025-04-11
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Resource Group
resourceType: Microsoft.Resources/resourceGroups
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Group.Naming/
---

# Resource Groups must use standard naming

## SYNOPSIS

Resource Groups without a standard naming convention may be difficult to identify and manage.

## DESCRIPTION

An effective naming convention allows operators to quickly identify resources, related systems, and their purpose.
Identifying resources easily is important to improve operational efficiency, reduce the time to respond to incidents,
and minimize the risk of human error.

Some of the benefits of using standardized tagging and naming conventions are:

- They provide consistency and clarity for resource identification and discovery across the Azure Portal, CLIs, and APIs.
- They enable filtering and grouping of resources for billing, monitoring, security, and compliance purposes.
- They support resource lifecycle management, such as provisioning, decommissioning, backup, and recovery.

For example, if you come upon a security incident, it's critical to quickly identify affected systems,
the functions that those systems support, and the potential business impact.

For resource groups, the Cloud Adoption Framework (CAF) suggests using the `rg-` prefix.

Requirements for Resource Group names:

- At least 1 character, but no more than 90.
- Can include alphanumeric, underscore, parentheses, hyphen, period (except at end).
- Resource group names must be unique within a subscription.

## RECOMMENDATION

Consider creating resource groups with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy resource groups that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
targetScope = 'subscription'

@minLength(1)
@maxLength(90)
@description('The name of the resource group.')
param name string

@description('The location resource group will be deployed.')
param location string

resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: name
  location: location
  tags: {
    environment: 'production'
    costCode: '349921'
  }
}
```

<!-- external:avm avm/res/resources/resource-group name -->

### Configure with Azure template

To deploy resource groups that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "metadata": {
    "_generator": {
      "name": "bicep",
      "version": "0.34.44.8038",
      "templateHash": "2313748121071500940"
    }
  },
  "parameters": {
    "name": {
      "type": "string",
      "minLength": 1,
      "maxLength": 90,
      "metadata": {
        "description": "The name of the resource group."
      }
    },
    "location": {
      "type": "string",
      "metadata": {
        "description": "The location resource group will be deployed."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.Resources/resourceGroups",
      "apiVersion": "2024-11-01",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "tags": {
        "environment": "production",
        "costCode": "349921"
      }
    }
  ]
}
```

## NOTES

This rule does not check if Resource Group names are unique.
Additionally, the following naming conventions that are related to managed resources are ignored:

- `NetworkWatcherRG`
- `AzureBackupRG_*`
- `DefaultResourceGroup-*`
- `cloud-shell-storage-*`
- `MC_*`

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_RESOURCE_GROUP_NAME_FORMAT -->

To configure this rule set the `AZURE_RESOURCE_GROUP_NAME_FORMAT` configuration value to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_RESOURCE_GROUP_NAME_FORMAT: '^rg-'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.resources/resourcegroups)
