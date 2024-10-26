---
reviewed: 2022-11-15
severity: Critical
pillar: Security
category: SE:02 Secured development lifecycle
resource: Deployment
online version: https://azure.github.io/PSRule.Rules.Azure/en/rules/Azure.Deployment.OuterSecret/
---

# Deployment exposes secrets with outer deployment

## SYNOPSIS

Outer evaluation deployments may leak secrets exposed as secure parameters into logs and nested deployments.

## DESCRIPTION

Template child deployments can be scoped as either `outer` or `inner`.
When using `outer` scope evaluated deployments, parameters from the parent template are used directly within nested
templates instead of enforcing `secureString` and `secureObject` types.

When passing secure values to nested deployments always use `inner` scope deployments to ensure secure values are not logging.
Bicep modules always use `inner` scope evaluated deployments.

<!-- security:note rotate-secret -->

## RECOMMENDATION

Consider using `inner` deployments to prevent secure values from being exposed.

## EXAMPLES

### Configure with Azure template

Nested Deployments within an ARM template need the property `expressionEvaluationOptions.Scope` to be set to `inner`.

```json
{
    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
    "contentVersion": "1.0.0.0",
    "parameters": {
        "adminUsername": {
            "type": "securestring",
            "defaultValue": "admin"
        }
    },
    "resources": [
         {
            "name": "nestedDeployment-A",
            "type": "Microsoft.Resources/deployments",
            "apiVersion": "2020-10-01",
            "properties": {
                "expressionEvaluationOptions": {
                    "scope": "inner"
                },
                "mode": "Incremental",
                "template": {
                    "$schema": "https://schema.management.azure.com/schemas/2019-04-01/deploymentTemplate.json#",
                    "contentVersion": "1.0.0.0",
                    "parameters": {
                        "adminUsername": {
                            "type": "securestring",
                            "defaultValue": "password"
                        }
                    },
                    "variables": {},
                    "resources": [
                        {
                            "apiVersion": "2019-12-01",
                            "type": "Microsoft.Compute/virtualMachines",
                            "name": "vm-example",
                            "location": "australiaeast",
                            "properties": {
                                "osProfile": {
                                    "computerName": "vm-example",
                                    "adminUsername": "[parameters('adminUsername')]"
                                }
                            }
                        }
                    ]
                }
            }
        }
    ]
}

```

### Configure with Bicep

This does not apply to Bicep code as under normal circumstances.
If you use the `module` keyword your deployments always use the `inner` evaluation mode.

## LINKS

- [SE:02 Secured development lifecycle](https://learn.microsoft.com/azure/well-architected/security/secure-development-lifecycle)
- [Azure deployment reference](https://learn.microsoft.com/azure/templates/microsoft.resources/deployments?pivots=deployment-language-bicep)
- [Deployment Function Scopes](https://learn.microsoft.com/azure/azure-resource-manager/templates/scope-functions?tabs=azure-powershell#function-resolution-in-scopes)
