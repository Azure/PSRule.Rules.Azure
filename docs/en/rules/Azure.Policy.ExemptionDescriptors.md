---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Policy
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Policy.ExemptionDescriptors/
---

# Use descriptive policy exemptions

## SYNOPSIS

Policy exemptions should use a display name and description.

## DESCRIPTION

Policy assignments can be configured with a display name and description.
Use these additional properties to clearly convey the reason for the policy exemption.
Additionally, consider providing a link or reference to track exemption conditions and approval.

## RECOMMENDATION

Consider setting a display name and description for each policy exemption.

## EXAMPLES

### Azure templates

To deploy policy exemptions that pass this rule:

- Set the `properties.displayName` property with a valid value.
- Set the `properties.description` property with a valid value.

For example:

```json
{
    "comments": "An example exemption.",
    "name": "exemption-001",
    "type": "Microsoft.Authorization/policyExemptions",
    "apiVersion": "2020-07-01-preview",
    "properties": {
        "policyAssignmentId": "<assignment_id>",
        "policyDefinitionReferenceIds": [],
        "exemptionCategory": "Waiver",
        "expiresOn": "2021-04-27T14:00:00Z",
        "displayName": "Exemption 001",
        "description": "An example exemption.",
        "metadata": {
            "requestedBy": "Apps team",
            "approvedBy": "Security team",
            "createdBy": "DevOps pipeline"
        }
    }
}
```

## LINKS

- [Azure Policy exemption structure](https://learn.microsoft.com/azure/governance/policy/concepts/exemption-structure)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.authorization/policyexemptions)
- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
