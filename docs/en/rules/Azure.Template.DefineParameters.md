---
deprecated: true
severity: Awareness
pillar: Operational Excellence
category: Release engineering
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.DefineParameters/
---

# Define template parameters

## SYNOPSIS

Each Azure Resource Manager (ARM) template file should contain a minimal number of parameters.

## DESCRIPTION

Azure templates support parameters, which are inputs you can specify when deploying the template resources.
Each template can support up to 256 parameters.

When defining template parameters:

- Minimize the number of parameters that require input by specifying a `defaultValue`.
- Use parameters for resource names and deployment locations.
- Use variables or literal resource properties for values that don't change.

## RECOMMENDATION

Consider defining a minimal number of parameters to make the template reusable.

## EXAMPLES

### Configure with Azure template

To author templates that pass this rule:

- Define at least one parameter.

For example:

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "metadata": {
        "name": "Managed Identity",
        "description": "Create or update a Managed Identity."
    },
    "parameters": {
        "identityName": {
            "type": "string",
            "metadata": {
                "description": "The name of the Managed Identity."
            }
        },
        "location": {
            "type": "string",
            "defaultValue": "[resourceGroup().location]",
            "metadata": {
                "description": "The Azure region to deploy to.",
                "example": "eastus"
            }
        },
        "tags": {
            "type": "object",
            "metadata": {
                "description": "Tags to apply to the resource.",
                "example": {
                    "service": "app1",
                    "env": "prod"
                }
            }
        }
    },
    "variables": {
        "tenantId": "[subscription().tenantId]"
    },
    "resources": [
        {
            "comments": "Create or update a Managed Identity",
            "type": "Microsoft.ManagedIdentity/userAssignedIdentities",
            "apiVersion": "2018-11-30",
            "name": "[parameters('identityName')]",
            "location": "[parameters('location')]",
            "properties": {
                "tenantId": "[variables('tenantId')]"
            },
            "tags": "[parameters('tags')]"
        }
    ]
}
```

## NOTES

This rule is not applicable and ignored for templates generated with Bicep, PSArm and AzOps.
Generated templates from these tools may not require any parameters to be set.

This rule is deprecated from v1.36.0.
By default, PSRule will not evaluate this rule unless explicitly enabled.
See https://aka.ms/ps-rule-azure/deprecations.

## LINKS

- [Parameters](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-syntax#parameters)
- [ARM template best practices](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-best-practices#general-recommendations-for-parameters)
- [Release deployment](https://learn.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)
