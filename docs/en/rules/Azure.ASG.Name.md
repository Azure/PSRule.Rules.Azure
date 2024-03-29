---
reviewed: 2021-11-27
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: Application Security Group
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.ASG.Name/
---

# Use valid ASG names

## SYNOPSIS

Application Security Group (ASG) names should meet naming requirements.

## DESCRIPTION

When naming Azure resources, resource names must meet service requirements.
The requirements for ASG names are:

- Between 1 and 80 characters long.
- Alphanumerics, underscores, periods, and hyphens.
- Start with alphanumeric.
- End alphanumeric or underscore.
- ASG names must be unique within a resource group.

## RECOMMENDATION

Consider using names that meet Application Security Group naming requirements.
Additionally consider naming resources with a standard naming convention.

## EXAMPLES

### Configure with Azure template

To deploy Application Security Groups that pass this rule:

- Set `name` to a value that meets the requirements.

For example:

```json
{
  "type": "Microsoft.Network/applicationSecurityGroups",
  "apiVersion": "2022-01-01",
  "name": "[parameters('asgName')]",
  "location": "[parameters('location')]",
  "properties": {}
}
```

### Configure with Bicep

To deploy Application Security Groups that pass this rule:

- Set `name` to a value that meets the requirements.

For example:

```bicep
resource asg 'Microsoft.Network/applicationSecurityGroups@2022-01-01' = {
  name: asgName
  location:location
  properties: {}
}
```

## NOTES

This rule does not check if ASG names are unique.

## LINKS

- [Repeatable infrastructure](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure)
- [Naming rules and restrictions for Azure resources](https://learn.microsoft.com/azure/azure-resource-manager/management/resource-name-rules)
- [Recommended abbreviations for Azure resource types](https://learn.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.network/applicationSecurityGroups)
