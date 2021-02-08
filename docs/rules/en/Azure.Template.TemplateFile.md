---
severity: Important
pillar: Operational Excellence
category: Deployment
resource: All resources
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Template.TemplateFile.md
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

- [Template file structure](https://docs.microsoft.com/azure/azure-resource-manager/templates/template-syntax)
- [Define resources in Azure Resource Manager templates](https://docs.microsoft.com/azure/templates/)
- [Release deployment](https://docs.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)
