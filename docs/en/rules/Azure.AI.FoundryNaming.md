---
reviewed: 2025-007-10
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: AI Service
resourceType: Microsoft.CognitiveServices/accounts
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.AI.FoundryNaming/
---

# Azure AI Foundry accounts must use standard naming

## SYNOPSIS

Azure AI Foundry accounts without a standard naming convention may be difficult to identify and manage.

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

For Azure AI Foundry accounts (previously Cognitive Services),
the Cloud Adoption Framework (CAF) recommends using the `aif-` prefix.

Requirements for AI Foundry account names:

- At least 2 character, but no more than 64.
- Can include alphanumeric, and hyphen characters.
- Can only start and end with a letter or number.
- Azure AI Foundry accounts must be unique within a resource group.

## RECOMMENDATION

Consider creating Azure AI Foundry accounts with a standard name.
Additionally consider using Azure Policy to only permit creation using a standard naming convention.

## EXAMPLES

### Configure with Bicep

To deploy AI Foundry accounts that pass this rule:

- Set the `name` property to a string that matches the naming requirements.
- Optionally, consider constraining name parameters with `minLength` and `maxLength` attributes.

For example:

```bicep
@minLength(2)
@maxLength(64)
@description('The name of the resource.')
param name string

@description('The location resources will be deployed.')
param location string = resourceGroup().location

resource account 'Microsoft.CognitiveServices/accounts@2024-10-01' = {
  name: name
  location: location
  sku: {
    name: 'S0'
  }
  kind: 'AIServices'
  properties: {
    publicNetworkAccess: 'Disabled'
    networkAcls: {
      defaultAction: 'Deny'
    }
    disableLocalAuth: true
  }
}
```

<!-- external:avm avm/res/cognitive-services/account name -->

### Configure with Azure template

To deploy AI Foundry accounts that pass this rule:

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
      "templateHash": "1334073252436312734"
    }
  },
  "parameters": {
    "name": {
      "type": "string",
      "minLength": 2,
      "maxLength": 64,
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
      "type": "Microsoft.CognitiveServices/accounts",
      "apiVersion": "2024-10-01",
      "name": "[parameters('name')]",
      "location": "[parameters('location')]",
      "sku": {
        "name": "S0"
      },
      "kind": "AIServices",
      "properties": {
        "publicNetworkAccess": "Disabled",
        "networkAcls": {
          "defaultAction": "Deny"
        },
        "disableLocalAuth": true
      }
    }
  ]
}
```

## NOTES

This rule does not check if Azure AI Foundry accounts names are unique,
and specifically targets the resource type `Microsoft.CognitiveServices/accounts` with the `kind` = `AIServices`.

<!-- caf:note name-format -->

### Rule configuration

<!-- module:config rule AZURE_AI_SERVICES_NAME_FORMAT -->

To configure this rule set the `AZURE_AI_SERVICES_NAME_FORMAT` configuration value to a regular expression
that matches the required format.

For example:

```yaml
configuration:
  AZURE_AI_SERVICES_NAME_FORMAT: '^aif-'
```

## LINKS

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Define your naming convention](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.cognitiveservices/accounts)
