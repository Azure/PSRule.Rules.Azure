---
severity: Awareness
pillar: Operational Excellence
category: Release engineering
resource: All resources
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Template.DefineParameters.md
---

# Define template parameters

## SYNOPSIS

Each Azure Resource Manager (ARM) template file should contain a minimal number of parameters.

## DESCRIPTION

Azure templates support parameters, which are inputs you can specify when deploying the template resources.
Each template can support up to 256 parameters.

When defining template parameters:

- Minimize the number of parameters that require input by specifying a `defaultValue`.
- Use parameters for resource names and deployment locations.
- Use variables or literal resource properties for values that don't change.

## RECOMMENDATION

Consider defining a minimal number of parameters to make the template reusable.

## LINKS

- [Parameters](https://docs.microsoft.com/azure/azure-resource-manager/templates/template-syntax#parameters)
- [ARM template best practices](https://docs.microsoft.com/azure/azure-resource-manager/templates/template-best-practices#general-recommendations-for-parameters)
- [Release deployment](https://docs.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)
