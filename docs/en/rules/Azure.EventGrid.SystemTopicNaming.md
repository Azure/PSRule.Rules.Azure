---
reviewed: 2025-04-11
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Event Grid
resourceType: Microsoft.EventGrid/systemTopics
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.EventGrid.SystemTopicNaming/
---

# Event Grid System Topics must use standard naming

## SYNOPSIS

Event Grid system topics without a standard naming convention may be difficult to identify and manage.

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

For Event Grid system topics, the Cloud Adoption Framework (CAF) recommends using the `egst-` prefix.

Requirements for Event Grid system topic names:

- At least 3 character, but no more than 50.
- Can include alphanumeric, and hyphen characters.
- Event Grid system topics must be unique within a resource group.

## RECOMMENDATION

Consider creating Event Grid system topics with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy Event Grid topics that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
@minLength(3)
@maxLength(50)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

resource systemTopic 'Microsoft.EventGrid/systemTopics@2025-02-15' = {
  name: name
  location: location
  identity: {
    type: 'SystemAssigned'
  }
  properties: {
    source: storageId
    topicType: 'Microsoft.Storage.StorageAccounts'
  }
}
```

<!-- external:avm avm/res/event-grid/system-topic name -->

### Configure with Azure template

To deploy Event Grid topics that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "metadata": {
    "_generator": {
      "name": "bicep",
      "version": "0.34.44.8038",
      "templateHash": "2337278938882386088"
    }
  },
  "parameters": {
    "name": {
      "type": "string",
      "minLength": 3,
      "maxLength": 50,
      "metadata": {
        "description": "The name of the resource."
      }
    },
    "location": {
      "type": "string",
      "defaultValue": "[resourceGroup().location]",
      "metadata": {
        "description": "The location resources will be deployed."
      }
    },
    "storageId": {
      "type": "string",
      "metadata": {
        "description": "The resource ID of the storage account."
      }
    }
  },
  "resources": [
    {
      "type": "Microsoft.EventGrid/systemTopics",
      "apiVersion": "2025-02-15",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "identity": {
        "type": "SystemAssigned"
      },
      "properties": {
        "source": "[parameters('storageId')]",
        "topicType": "Microsoft.Storage.StorageAccounts"
      }
    }
  ]
}
```

## NOTES

This rule does not check if Event Grid system topic names are unique.

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_EVENTGRID_SYSTEM_TOPIC_NAME_FORMAT -->

To configure this rule set the `AZURE_EVENTGRID_SYSTEM_TOPIC_NAME_FORMAT` configuration value to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_EVENTGRID_SYSTEM_TOPIC_NAME_FORMAT: '^egst-'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.eventgrid/systemtopics)
