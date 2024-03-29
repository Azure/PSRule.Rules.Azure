---
severity: Awareness
pillar: Operational Excellence
category: Release engineering
resource: All resources
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Template.UseLocationParameter/
---

# Use a location parameter to specify resource location

## SYNOPSIS

Template should reference a location parameter to specify resource location.

## DESCRIPTION

The template parameter `location` is a standard parameter recommended for deployment templates.
The `location` parameter is a intended for specifying the deployment location of the primary resource.

When defining a resource that requires a location, use the `location` parameter. For example:

```json
{
    "type": "Microsoft.Network/virtualNetworks",
    "name": "[parameters('VNETName')]",
    "apiVersion": "2020-06-01",
    "location": "[parameters('location')]",
    "properties": {}
}
```

Additionally, the template may include other resources.
Use the `location` parameter value for resources that are likely to be in the same location.
This approach minimizes the number of times users are asked to provide location information.
For resources that aren't available in all locations, use a separate parameter.

## RECOMMENDATION

Consider using `parameters('location)` instead of `resourceGroup().location`.
Using a location parameter enabled users of the template to specify the location of deployed resources.

## EXAMPLES

### Configure with Azure template

To author templates that pass this rule:

- Define a parameter named `location`.
- Set the location of any deployed resources to `[parameters('location')]`.

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

This rule is not applicable and ignored for templates generated with Bicep, PSArm, and AzOps.
Generated templates from these tools may not require any parameters to be set.

## LINKS

- [ARM template best practices](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-best-practices#location-recommendations-for-parameters)
- [Parameters](https://learn.microsoft.com/azure/azure-resource-manager/templates/template-syntax#parameters)
- [Release deployment](https://learn.microsoft.com/azure/architecture/framework/devops/release-engineering-cd#automation)
