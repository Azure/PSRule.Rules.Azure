---
reviewed: 2025-10-26
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Azure SQL Elastic Job agent
resourceType: Microsoft.Sql/servers/jobAgents
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.SQL.JobAgentNaming/
---

# Azure SQL Elastic Job agent resources must use standard naming

## SYNOPSIS

Azure SQL Elastic Job agent resources without a standard naming convention may be difficult to identify and manage.

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

For Azure SQL Elastic Job agent, the Cloud Adoption Framework (CAF) recommends using the `sqlja-` prefix.

Requirements for Azure SQL Elastic Job agent resource names:

- Between 1 and 128 characters long.
- Letters, numbers, and special characters except: `<>*%&:\/?`
- Can't end with period or a space.
- Must be unique for each logical server.

## RECOMMENDATION

Consider creating Azure SQL Elastic Job agent resources with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy resources that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
@minLength(1)
@maxLength(128)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

resource agent 'Microsoft.Sql/servers/jobAgents@2024-05-01-preview' = {
  parent: server
  name: name
  location: location
  properties: {
    databaseId: database.id
  }
}
```

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
      "maxLength": 128,
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
      "type": "Microsoft.Sql/servers/jobAgents",
      "apiVersion": "2024-05-01-preview",
      "name": "[format('{0}/{1}', parameters('name'), parameters('name'))]",
      "location": "[parameters('location')]",
      "properties": {
        "databaseId": "[resourceId('Microsoft.Sql/servers/databases', parameters('name'), parameters('name'))]"
      }
    }
  ]
}
```

## NOTES

This rule does not check if Azure SQL Elastic Job agent resource names are unique.

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_SQL_JOB_AGENT_NAME_FORMAT -->

To configure this rule set the `AZURE_SQL_JOB_AGENT_NAME_FORMAT` configuration value to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_SQL_JOB_AGENT_NAME_FORMAT: '^sqlja-'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Operational Excellence: Level 2](https://learn.microsoft.com/azure/well-architected/operational-excellence/maturity-model?tabs=level2)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Parameters in Bicep](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters)
- [Bicep functions](https://learn.microsoft.com/azure/azure-resource-manager/bicep/bicep-functions)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.sql/servers/jobagents)
