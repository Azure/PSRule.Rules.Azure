---
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Policy
resourceType: Microsoft.Authorization/policyDefinitions,Microsoft.Authorization/policySetDefinitions
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Policy.DefinitionVersion/
---

# Set version metadata for policy definitions

## SYNOPSIS

Policy and initiative definitions should set the version metadata.

## DESCRIPTION

Policy definitions and initiatives can set the `version` metadata.
Built-in policies use this metadata and it is recommended in Azure Policy documentation.

Setting a version helps to track changes to custom policy definitions and initiatives over time.

## RECOMMENDATION

Consider setting `version` metadata for each custom policy definition and initiative.

## EXAMPLES

### Azure templates

To deploy policy definitions that pass this rule:

- Set the `properties.metadata.version` property with a valid value.

For example:

```json
{
    "type": "Microsoft.Authorization/policyDefinitions",
    "apiVersion": "2021-06-01",
    "name": "policy-001",
    "properties": {
        "displayName": "Policy 001",
        "description": "An example policy definition.",
        "policyType": "Custom",
        "mode": "All",
        "metadata": {
            "category": "Tags",
            "version": "1.0.0"
        },
        "policyRule": {
            "if": {
                "field": "tags['environment']",
                "exists": "false"
            },
            "then": {
                "effect": "audit"
            }
        }
    }
}
```

To deploy initiatives that pass this rule:

- Set the `properties.metadata.version` property with a valid value.

For example:

```json
{
    "type": "Microsoft.Authorization/policySetDefinitions",
    "apiVersion": "2021-06-01",
    "name": "initiative-001",
    "properties": {
        "displayName": "Initiative 001",
        "description": "An example initiative.",
        "policyType": "Custom",
        "metadata": {
            "category": "Tags",
            "version": "1.0.0"
        },
        "policyDefinitions": [
            {
                "policyDefinitionId": "[subscriptionResourceId('Microsoft.Authorization/policyDefinitions', 'policy-001')]"
            }
        ]
    }
}
```

## LINKS

- [Azure Policy definition structure](https://learn.microsoft.com/azure/governance/policy/concepts/definition-structure-basics)
- [Built-in policy metadata](https://github.com/Azure/azure-policy/blob/master/built-in-policies/README.md)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.authorization/policydefinitions)
- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
