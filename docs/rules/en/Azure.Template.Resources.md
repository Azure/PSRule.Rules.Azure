---
severity: Awareness
pillar: Operational Excellence
category: Deployment
resource: All resources
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Template.Resources.md
---

# Include a template resource

## SYNOPSIS

Each Azure Resource Manager (ARM) template file should deploy at least one resource.

## DESCRIPTION

An ARM template file is used to create or update one or more Azure resources.
The `resources` property of an ARM template includes a definition of the resources to deploy.

## RECOMMENDATION

Consider removing Azure template files that do not deploy any resources.

## LINKS

- [Resources](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-syntax#resources)
- [Tutorial: Create and deploy your first ARM template](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-tutorial-create-first-template)
