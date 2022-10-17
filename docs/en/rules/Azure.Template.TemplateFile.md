---
severity: Important
pillar: Operational Excellence
category: Repeatable infrastructure
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

## LINKS

- [Automate deployments with ARM Templates](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure#automate-deployments-with-arm-templates)
- [Template file structure](https://docs.microsoft.com/azure/azure-resource-manager/templates/template-syntax)
- [Define resources in Azure Resource Manager templates](https://docs.microsoft.com/azure/templates/)
