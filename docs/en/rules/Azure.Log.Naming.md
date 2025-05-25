---
reviewed: 2025-05-25
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Azure Monitor Logs
resourceType: Microsoft.OperationalInsights/workspaces
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Log.Naming/
---

# Log workspaces must use standard naming

## SYNOPSIS

Azure Monitor Log workspaces without a standard naming convention may be difficult to identify and manage.

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

For Azure Monitor Log workspaces, the Cloud Adoption Framework (CAF) recommends using the `log-` prefix.

The requirements for Azure Monitor Log workspace names are:

- Between 3 and 63 characters long.
- Letters, numbers, and hyphens.
- Must start and end with a letter or number.
- Resource names must be unique within a resource group.

## RECOMMENDATION

Consider creating Azure Monitor Log workspaces with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy workspaces that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
@minLength(4)
@maxLength(63)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

param secondaryLocation string

// An example Log Analytics workspace with replication enabled.
resource workspace 'Microsoft.OperationalInsights/workspaces@2025-02-01' = {
  name: name
  location: location
  properties: {
    replication: {
      enabled: true
      location: secondaryLocation
    }
    publicNetworkAccessForIngestion: 'Enabled'
    publicNetworkAccessForQuery: 'Enabled'
    retentionInDays: 30
    features: {
      disableLocalAuth: true
    }
    sku: {
      name: 'PerGB2018'
    }
  }
}
```

<!-- external:avm avm/res/operational-insights/workspace name -->

### Configure with Azure template

To deploy workspaces that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": {
    "name": {
      "type": "string",
      "minLength": 4,
      "maxLength": 63,
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
    "secondaryLocation": {
      "type": "string"
    }
  },
  "resources": [
    {
      "type": "Microsoft.OperationalInsights/workspaces",
      "apiVersion": "2025-02-01",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "properties": {
        "replication": {
          "enabled": true,
          "location": "[parameters('secondaryLocation')]"
        },
        "publicNetworkAccessForIngestion": "Enabled",
        "publicNetworkAccessForQuery": "Enabled",
        "retentionInDays": 30,
        "features": {
          "disableLocalAuth": true
        },
        "sku": {
          "name": "PerGB2018"
        }
      }
    }
  ]
}
```

## NOTES

This rule does not check if workspaces names are unique.

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_LOG_WORKSPACE_NAME_FORMAT -->

To configure this rule set the `AZURE_LOG_WORKSPACE_NAME_FORMAT` configuration to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_LOG_WORKSPACE_NAME_FORMAT: '^log-'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure resource deployment](https://learn.microsoft.com/azure/templates/microsoft.operationalinsights/workspaces)
