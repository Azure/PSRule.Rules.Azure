---
severity: Important
pillar: Operational Excellence
category: Release engineering
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.ParameterMinMaxValue/
---

# Use minValue and maxValue with correct type

## SYNOPSIS

Template parameters `minValue` and `maxValue` constraints must be valid.

## DESCRIPTION

When defining Azure template parameters the `minValue` or `maxValue` constraints can be added to parameters.
These constraints are only valid for parameters using the `int` type.
When configuring `minValue` and `maxValue` an integer must be used.

## RECOMMENDATION

Consider updating parameter definitions using `minValue` or `maxValue`.
When using `minValue` or `maxValue` these values must be integers and only apply to `int` parameters.

## LINKS

- [Parameters](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-syntax#parameters)
- [ARM template best practices](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-best-practices#general-recommendations-for-parameters)
- [Release deployment](https://learn.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)
