---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.TemplateSchema/
---

# Use a recent template schema version

## SYNOPSIS

Use a more recent version of the Azure template schema.

## DESCRIPTION

The JSON schemas used to define Azure templates are versioned.
When defining templates use templates with a supported schema.

The following template schemas are deprecated:

- `https://schema.management.azure.com/schemas/2015-01-01/deploymentTemplate.json#`

## RECOMMENDATION

Consider using a more recent schema version for Azure template files.

## EXAMPLES

### Configure with Azure template

To define Azure template files that pass this rule:

- Configure the template schema to one of the following:
  - `https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#`
  - `https://schema.management.azure.com/schemas/2018-05-01/subscriptionDeploymentTemplate.json#`
  - `https://schema.management.azure.com/schemas/2019-08-01/tenantDeploymentTemplate.json#`
  - `https://schema.management.azure.com/schemas/2019-08-01/managementGroupDeploymentTemplate.json#`

For example:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": { },
    "functions": [],
    "resources": [ ]
}
```

## LINKS

- [Automate deployments with ARM Templates](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure#automate-deployments-with-arm-templates)
- [Test cases for ARM templates](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-test-cases)
- [Template file structure](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-syntax)
