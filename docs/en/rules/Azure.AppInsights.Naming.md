---
reviewed: 2025-05-25
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Application Insights
resourceType: Microsoft.Insights/components
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AppInsights.Naming/
---

# Application Insights resources must use standard naming

## SYNOPSIS

Application Insights resources without a standard naming convention may be difficult to identify and manage.

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

For Application Insights, the Cloud Adoption Framework (CAF) recommends using the `appi-` prefix.

The requirements for Application Insights resource names are:

- Between 1 and 255 characters long.
- Letters, numbers, hyphens, periods, underscores, and parenthesis.
- Must not end in a period.
- Resource names must be unique within a resource group.

## RECOMMENDATION

Consider creating Application Insights with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy resources that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
@minLength(1)
@maxLength(255)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

resource appInsights 'Microsoft.Insights/components@2020-02-02' = {
  name: name
  location: location
  kind: 'web'
  properties: {
    Application_Type: 'web'
    Flow_Type: 'Redfield'
    Request_Source: 'IbizaAIExtension'
    WorkspaceResourceId: workspaceId
    DisableLocalAuth: true
  }
}
```

<!-- external:avm avm/res/insights/component name -->

### Configure with Azure template

To deploy resources that pass this rule:

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
      "minLength": 1,
      "maxLength": 255,
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
    }
  },
  "resources": [
    {
      "type": "Microsoft.Insights/components",
      "apiVersion": "2020-02-02",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "kind": "web",
      "properties": {
        "Application_Type": "web",
        "Flow_Type": "Redfield",
        "Request_Source": "IbizaAIExtension",
        "WorkspaceResourceId": "[parameters('workspaceId')]",
        "DisableLocalAuth": true
      }
    }
  ]
}
```

## NOTES

This rule does not check if Application Insights resource names are unique.

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_APP_INSIGHTS_NAME_FORMAT -->

To configure this rule set the `AZURE_APP_INSIGHTS_NAME_FORMAT` configuration to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_APP_INSIGHTS_NAME_FORMAT: '^appi-'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.insights/components)
