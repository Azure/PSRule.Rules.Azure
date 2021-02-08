---
severity: Important
pillar: Operational Excellence
category: Release engineering
resource: All resources
online version: https://github.com/Microsoft/PSRule.Rules.Azure/blob/main/docs/rules/en/Azure.Template.ParameterMinMaxValue.md
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

- [Parameters](https://docs.microsoft.com/azure/azure-resource-manager/templates/template-syntax#parameters)
- [ARM template best practices](https://docs.microsoft.com/azure/azure-resource-manager/templates/template-best-practices#general-recommendations-for-parameters)
- [Release deployment](https://docs.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)
