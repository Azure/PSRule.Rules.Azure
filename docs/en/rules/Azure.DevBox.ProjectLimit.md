---
reviewed: 2024-01-23
severity: Important
pillar: Cost Optimization
category: CO:04 Spending guardrails
resource: Dev Box
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.DevBox.ProjectLimit/
---

# Limit number of Dev Boxes per user

## SYNOPSIS

Limit the number of Dev Boxes a single user can create for a project.

## DESCRIPTION

Microsoft Dev Box is a service that allows users to create and manage a developer workstation in the cloud (Dev Boxes).
Dev Boxes are virtual machines with specifications and configuration designed for developers.
Each Dev Box is billed based on usage to a capped amount per month.

Dev Box Projects are used to manage Dev Boxes.
By default, a single user can create multiple Dev Boxes for a single Dev Box Project.
This can lead to unexpected costs.

Organizations should consider how many Dev Boxes are required for a single user and set reasonable limits.

## RECOMMENDATION

Consider limiting the number of Dev Boxes a single user can create for any projects.
Additional consider, configuring budgets and alerts to monitor cost exceptions.

## EXAMPLES

### Configure with Azure template

To deploy Dev Box Projects that pass this rule:

- Set the `properties.maxDevBoxesPerUser` property to limit the number of Dev Box a single user can create.
  E.g. `2`

For example:

```json
{
  "type": "Microsoft.DevCenter/projects",
  "apiVersion": "2023-04-01",
  "name": "[parameters('name')]",
  "location": "[parameters('location')]",
  "properties": {
    "devCenterId": "[resourceId('Microsoft.DevCenter/devcenters', parameters('name'))]",
    "maxDevBoxesPerUser": 2
  },
  "dependsOn": [
    "[resourceId('Microsoft.DevCenter/devcenters', parameters('name'))]"
  ]
}
```

### Configure with Bicep

To deploy Dev Box Projects that pass this rule:

- Set the `properties.maxDevBoxesPerUser` property to limit the number of Dev Box a single user can create.
  E.g. `2`

For example:

```bicep
resource project 'Microsoft.DevCenter/projects@2023-04-01' = {
  name: name
  location: location
  properties: {
    devCenterId: center.id
    maxDevBoxesPerUser: 2
  }
}
```

## NOTES

The `properties.maxDevBoxesPerUser` property does not limit the number of Dev Boxes a user can create across multiple projects.

## LINKS

- [CO:04 Spending guardrails](https://learn.microsoft.com/azure/well-architected/cost-optimization/set-spending-guardrails)
- [Tutorial: Control costs by setting dev box limits on a project](https://learn.microsoft.com/azure/dev-box/tutorial-dev-box-limits)
- [Tutorial: Create and manage budgets](https://learn.microsoft.com/azure/cost-management-billing/costs/tutorial-acm-create-budgets)
- [Quickstart: Create a budget with Bicep](https://learn.microsoft.com/azure/cost-management-billing/costs/quick-create-budget-bicep)
- [Use cost alerts to monitor usage and spending](https://learn.microsoft.com/azure/cost-management-billing/costs/cost-mgt-alerts-monitor-usage-spending)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.devcenter/projects)
