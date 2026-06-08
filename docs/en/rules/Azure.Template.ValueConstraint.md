---
reviewed: 2026-06-07
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.ValueConstraint/
---

# Template values should satisfy constraints

## SYNOPSIS

Set parameter and output values to satisfy template constraints.

## DESCRIPTION

Azure Resource Manager (ARM) templates can define constraints for parameter and output values. Bicep decorators such as `@allowed`, `@minLength`, `@maxLength`, `@minValue`, `@maxValue`, and `@validate` compile into these template constraints.

When templates are expanded, this rule checks resolved parameter and output values against the compiled constraint fields:

- `allowedValues`
- `minLength`
- `maxLength`
- `minValue`
- `maxValue`
- `validate`

If a `validate` constraint includes a custom message, the message is used as the rule reason.

## RECOMMENDATION

Consider updating the supplied value to satisfy the parameter or output constraint.

## EXAMPLES

### Configure with Bicep

To configure deployments that pass this rule:

- Use values that satisfy decorators on parameters and outputs.

For example:

```bicep
@allowed([
  'Standard'
  'Premium'
])
param skuName string = 'Standard'

@minValue(1)
param replicaCount int = 1
```

## NOTES

This rule evaluates the compiled ARM template constraint shape emitted by Bicep. It does not parse Bicep source files directly.

## LINKS

- [Deployment considerations for DevOps](https://learn.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)
- [Bicep decorators](https://learn.microsoft.com/azure/azure-resource-manager/bicep/parameters#decorators)
