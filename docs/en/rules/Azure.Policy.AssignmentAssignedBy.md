---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Policy
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Policy.AssignmentAssignedBy/
---

# Use assigned by for policy assignments

## SYNOPSIS

Policy assignments should use `assignedBy` metadata.

## DESCRIPTION

When using the Azure Portal, policy assignment automatically set the `assignedBy` metadata.
This metadata field is intended to indicate the person or team assigning the policy to a resource scope.

When automating policy management, it may be helpful to identify assignments managed by code.

## RECOMMENDATION

Consider setting `assignedBy` metadata for each policy assignment.

## EXAMPLES

### Azure templates

To deploy policy assignments that pass this rule:

- Set the `properties.metadata.assignedBy` property with a valid value.

For example:

```json
{
    "comments": "Initiative assignment",
    "name": "assignment-001",
    "type": "Microsoft.Authorization/policyAssignments",
    "apiVersion": "2019-06-01",
    "properties": {
        "displayName": "Assignment 001",
        "description": "An example policy assignment.",
        "metadata": {
            "assignedBy": "DevOps pipeline"
        },
        "enforcementMode": "Default"
    }
}
```

## LINKS

- [Azure Policy assignment structure](https://learn.microsoft.com/azure/governance/policy/concepts/assignment-structure)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.authorization/policyassignments)
- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
