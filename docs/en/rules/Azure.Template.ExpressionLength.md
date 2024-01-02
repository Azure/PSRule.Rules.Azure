---
reviewed: 2021-11-21
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.ExpressionLength/
---

# Template expressions should not exceed a maximum length

## SYNOPSIS

Template expressions should not exceed the maximum length.

## DESCRIPTION

Extremely long expressions may be difficult to read and debug.
Avoid using expressions that exceed 24,576 characters in length.

## RECOMMENDATION

Consider updating the expression to reduce complexity and length.

## NOTES

This rule is not applicable and ignored for templates generated with Bicep, PSArm, and AzOps.
Generated templates from these tools may not require any parameters to be set.

## LINKS

- [Deployment considerations for DevOps](https://learn.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)
- [Template limits](https://docs.microsoft.com/azure/azure-resource-manager/templates/best-practices#template-limits)
