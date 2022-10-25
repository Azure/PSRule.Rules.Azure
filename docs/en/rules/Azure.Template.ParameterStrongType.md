---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.ParameterStrongType/
---

# Parameter value should match strong type

## SYNOPSIS

Set the parameter value to a value that matches the specified strong type.

## DESCRIPTION

Template string parameters can optionally specify a strong type.
When parameter files are expanded, if the parameter value does not match the type this rule fails.
Support is provided by PSRule for Azure for the following types:

- Resource type - Specify a resource type.
  For example `Microsoft.OperationalInsights/workspaces`.
  If a resource type is specified the parameter value must be a resource id of that type.
- Location - Specify `location` as the strong type.
  If `location` is specified, the parameter value must be a valid Azure location.

## RECOMMENDATION

Consider updating the parameter value to a value that matches the specifed strong type.

## LINKS

- [Deployment considerations for DevOps](https://learn.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)
- [Strong type](https://azure.github.io/PSRule.Rules.Azure/using-templates/#strongtype)
