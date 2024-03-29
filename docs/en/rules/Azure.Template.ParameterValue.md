---
severity: Awareness
pillar: Operational Excellence
category: Repeatable infrastructure
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.ParameterValue/
---

# Specify a value for each parameter

## SYNOPSIS

Specify a value for each parameter in template parameter files.

## DESCRIPTION

When defining a template parameter file:

- Uou must specify a value for each parameter in the file.
- If the parameter is optional, you can omit the parameter from the file.
- If the parameter is required, you must specify a value for the parameter.

## RECOMMENDATION

Consider defining a value for each parameter in the template parameter file.

## EXAMPLES

### Configure with Azure template

To define Azure template parameter files that pass this rule:

- Set a value for each parameter specified in the file.

For example:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentParameters.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "parameter1": {
            "value": "value1"
        },
        "parameter2": {
            "value": []
        }
    }
}
```

## LINKS

- [Automate deployments with ARM Templates](https://learn.microsoft.com/azure/architecture/framework/devops/automation-infrastructure#automate-deployments-with-arm-templates)
- [Test cases for parameter files](https://learn.microsoft.com/azure/azure-resource-manager/templates/parameter-file-test-cases#parameters-must-contain-values)
- [Create Resource Manager parameter file](https://learn.microsoft.com/azure/azure-resource-manager/templates/parameter-files)
- [Parameters in Azure Resource Manager templates](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-parameters)
