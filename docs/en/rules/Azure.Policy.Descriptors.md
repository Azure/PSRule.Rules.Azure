---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Policy
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Policy.Descriptors/
---

# Use descriptive policies

## SYNOPSIS

Policy and initiative definitions should use a display name, description, and category.

## DESCRIPTION

Policy and initiative definitions can be configured with a display name, description, and category.
Use these additional properties to clearly convey the purpose when creating custom definitions.

## RECOMMENDATION

Consider setting a display name, description and category for each policy and initiatives definition.

## EXAMPLES

### Azure templates

To deploy initiative and policy definitions that pass this rule:

- Set the `properties.displayName` property with a valid value.
- Set the `properties.description` property with a valid value.
- Set the `properties.metadata.category` property with a valid value.

For example:

```json
{
    "comments": "Initiative definition",
    "name": "initiative-001",
    "type": "Microsoft.Authorization/policySetDefinitions",
    "apiVersion": "2019-06-01",
    "properties": {
        "policyType": "Custom",
        "displayName": "Initiative 001",
        "description": "An example initiative.",
        "metadata": {
            "category": "Security"
        },
        "policyDefinitions": []
    }
}
```

## LINKS

- [Azure Policy definition structure](https://learn.microsoft.com/azure/governance/policy/concepts/definition-structure#display-name-and-description)
- [Common metadata properties](https://learn.microsoft.com/azure/governance/policy/concepts/definition-structure#common-metadata-properties)
- [Policy definition template reference](https://learn.microsoft.com/azure/templates/microsoft.authorization/policydefinitions)
- [Initiative definition template reference](https://learn.microsoft.com/azure/templates/microsoft.authorization/policysetdefinitions)
- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
