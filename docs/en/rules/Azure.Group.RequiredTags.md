---
reviewed: 2025-04-27
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Resource Group
resourceType: Microsoft.Resources/resourceGroups
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Group.RequiredTags/
---

# Resource Groups must use standard tagging

## SYNOPSIS

Resource groups without a standard tagging convention may be difficult to identify and manage.

## DESCRIPTION

An effective tagging convention allows operators to quickly identify, classify, group, and report on resources.
Identifying resources and their related systems easily is important to improve operational efficiency,
reduce the time to respond to incidents, and minimize the risk of human error.

Some of the benefits of using standardized tagging and naming conventions are:

- They provide consistency and clarity for resource identification and discovery across the Azure Portal, CLIs, and APIs.
- They enable filtering and grouping of resources for billing, monitoring, security, and compliance purposes.
- They support resource lifecycle management, such as provisioning, decommissioning, backup, and recovery.

For example, if you come upon a security incident, it's critical to quickly identify affected systems,
the functions that those systems support, and the potential business impact.

Each resource groups supports up to 50 tags.

## RECOMMENDATION

Consider tagging resource groups with the tags required by your organization.
Additionally consider enforcing required tags at runtime with Azure Policy.

## EXAMPLES

### Configure with Bicep

To deploy resource groups that pass this rule:

- Set the `tags` property to an object that contains each required tag as a key/ value.
- Optionally, consider using a custom type to define the required tags.

For example:

```bicep
targetScope = 'subscription'

@minLength(1)
@maxLength(90)
@description('The name of the resource group.')
param name string

@description('The location resource group will be deployed.')
param location string

@description('Tags to assign to the resource group.')
param tags requiredTags

@description('A custom type defining the required tags on a resource groups.')
type requiredTags = {
  Env: string
  CostCode: string
}

resource rg 'Microsoft.Resources/resourceGroups@2024-11-01' = {
  name: name
  location: location
  tags: tags
}
```

<!-- external:avm avm/res/resources/resource-group tags -->

### Configure with Azure template

To deploy resource groups that pass this rule:

- Set the `tags` property to an object that contains each required tag as a key/ value.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#",
  "languageVersion": "2.0",
  "contentVersion": "1.0.0.0",
  "metadata": {
    "_generator": {
      "name": "bicep",
      "version": "0.34.44.8038",
      "templateHash": "6956494957227333099"
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
    },
    "tags": {
      "type": "object",
      "metadata": {
        "description": "Tags to assign to the resource group."
      }
    }
  },
  "resources": {
    "rg": {
      "type": "Microsoft.Resources/resourceGroups",
      "apiVersion": "2024-11-01",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "tags": "[parameters('tags')]"
    }
  }
}
```

## NOTES

This rule does not prevent additional tags from being added to the resource group in addition to the required tags.

### Rule configuration

<!-- module:config rule AZURE_RESOURCE_GROUP_REQUIRED_TAGS -->

To configure this rule set the `AZURE_RESOURCE_GROUP_REQUIRED_TAGS` configuration value to a list of required tags names.
The tag names are case-sensitive.

For example:

```yaml
configuration:
  AZURE_RESOURCE_GROUP_REQUIRED_TAGS: [ 'Env', 'Criticality' ]
```

Additionally, you can specify a configuration value named with the format `AZURE_TAG_FORMAT_FOR_<TAG_NAME>`.
This configuration value is used to specify the format of the tag value and constrain the value to a specific format.
For example, if you have a tag named `Env`, you can specify the format of the value with the configuration value `AZURE_TAG_FORMAT_FOR_ENV`.

```yaml
configuration:
  AZURE_TAG_FORMAT_FOR_ENV: '^(prod|dev|test)$'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Define your tagging strategy](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging)
- [Use tags to organize your Azure resources and management hierarchy](https://learn.microsoft.com/azure/azure-resource-manager/management/tag-resources)
- [Tag support for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/tag-support)
- [User-defined data types in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/user-defined-data-types)
- [Imports in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-import)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.resources/resourcegroups)
