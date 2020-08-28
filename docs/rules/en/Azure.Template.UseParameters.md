---
severity: Awareness
pillar: Operational Excellence
category: Deployment
resource: All resources
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Template.UseParameters.md
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

- [ARM template best practices](https://docs.microsoft.com/en-us/azure/azure-resource-manager/templates/template-best-practices#general-recommendations-for-parameters)
