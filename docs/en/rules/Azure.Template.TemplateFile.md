---
reviewed: 2024-01-27
severity: Important
pillar: Operational Excellence
category: OE:05 Infrastructure as code
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.TemplateFile/
---

# Use ARM template file structure

## SYNOPSIS

Use ARM template files that are valid.

## DESCRIPTION

Azure Resource Manager (ARM) template files have a pre-defined structure.
ARM templates require `$schema`, `contentVersion` and `resources` sections to be defined.
If any of these sections are missing, ARM will not accept the template.

## RECOMMENDATION

Consider reviewing the requirements for this file.
Also consider using Visual Studio Code to assist with authoring these files.

## EXAMPLES

### Configure with Azure template

To define Azure template files that pass this rule:

- Always specify the required properties `$schema`, `contentVersion` and `resources` properties.
- Optional specify `languageVersion`, `definitions`, `metadata`, `parameters`, `functions`, `variables`, and `outputs` properties.
- Avoid specifying any other properties.

For example:

```json
{
  "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
  "contentVersion": "1.0.0.0",
  "parameters": { },
  "variables":  { },
  "resources": [ ]
}
```

## NOTES

This rule is not applicable to Azure Bicep files as they have a different structure.
If you are running analysis over pre-built Bicep files and they generate a rule failure,
please raise an [issue](https://github.com/Azure/PSRule.Rules.Azure/issues/new/choose).

## LINKS

- [OE:05 Infrastructure as code](https://learn.microsoft.com/azure/well-architected/operational-excellence/infrastructure-as-code-design)
- [Template file structure](https://learn.microsoft.com/azure/azure-resource-manager/templates/syntax)
- [Define resources in Azure Resource Manager templates](https://learn.microsoft.com/azure/templates/)
