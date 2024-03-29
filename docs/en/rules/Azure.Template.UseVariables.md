---
severity: Awareness
pillar: Operational Excellence
category: Release engineering
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.UseVariables/
---

# Remove unused template variables

## SYNOPSIS

Each Azure Resource Manager (ARM) template variable should be used or removed from template files.

## DESCRIPTION

ARM templates can optionally define variables that can be reused throughout the template.
Variables that are not used may add template complexity for no benefit.

## RECOMMENDATION

Consider removing unused variables from Azure template files.

## LINKS

- [Variables](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-syntax#variables)
- [ARM template best practices](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-best-practices#variables)
- [Release deployment](https://learn.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)
