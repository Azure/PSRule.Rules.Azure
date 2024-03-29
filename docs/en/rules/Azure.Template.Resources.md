---
severity: Awareness
pillar: Operational Excellence
category: Release engineering
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.Resources/
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

- [Resources](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-syntax#resources)
- [Tutorial: Create and deploy your first ARM template](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-tutorial-create-first-template)
- [Release deployment](https://learn.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)
