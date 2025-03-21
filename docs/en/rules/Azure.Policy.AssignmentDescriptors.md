---
severity: Awareness
pillar: Operational Excellence
category: OE:04 Tools and processes
resource: Policy
resourceType: Microsoft.Authorization/policyAssignments
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Policy.AssignmentDescriptors/
---

# Use descriptive policy assignments

## SYNOPSIS

Policy assignments should use a display name and description.

## DESCRIPTION

Policy assignments can be configured with a display name and description.
Use these additional properties to clearly convey the intent of the policy assignment.

## RECOMMENDATION

Consider setting a display name and description for each policy assignment.

## EXAMPLES

### Azure templates

To deploy policy assignments that pass this rule:

- Set the `properties.displayName` property with a valid value.
- Set the `properties.description` property with a valid value.

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

- [OE:04 Tools and processes](https://learn.microsoft.com/azure/well-architected/operational-excellence/tools-processes)
- [Azure Policy assignment structure](https://learn.microsoft.com/azure/governance/policy/concepts/assignment-structure)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.authorization/policyassignments)
