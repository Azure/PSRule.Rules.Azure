---
severity: Important
pillar: Operational Excellence
category: Repeatable infrastructure
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.ParameterFile/
---

# Use ARM parameter file structure

## SYNOPSIS

Use ARM template parameter files that are valid.

## DESCRIPTION

Azure Resource Manager (ARM) template parameter files have a pre-defined structure.
ARM template parameter files require `$schema`, `contentVersion` and `parameters` sections to be defined.
If any of these sections are missing, ARM will not accept the parameter file.

## RECOMMENDATION

Consider reviewing the requirements for this file.
Also consider using Visual Studio Code to assist with authoring these files.

## LINKS

- [Automate deployments with ARM Templates](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure#automate-deployments-with-arm-templates)
- [Test cases for parameter files](https://learn.microsoft.com/azure/azure-resource-manager/templates/parameter-file-test-cases)
- [Create Resource Manager parameter file](https://learn.microsoft.com/azure/azure-resource-manager/templates/parameter-files)
- [Parameters in Azure Resource Manager templates](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-parameters)
