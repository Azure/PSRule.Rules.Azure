---
severity: Awareness
pillar: Operational Excellence
category: Release engineering
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.UseParameters/
---

# Remove unused template parameters

## SYNOPSIS

Each Azure Resource Manager (ARM) template parameter should be used or removed from template files.

## DESCRIPTION

ARM templates can optionally define parameters that can be reused throughout the template.
Parameters that are not used may make template use more complex for no benefit.

## RECOMMENDATION

Consider removing unused parameters from Azure template files.

## LINKS

- [Parameters](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-syntax#parameters)
- [ARM template best practices](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-best-practices#general-recommendations-for-parameters)
- [Release deployment](https://learn.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)
